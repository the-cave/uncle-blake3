# frozen_string_literal: true

require 'json'

RSpec.describe ::UncleBlake3::Digest do
  it 'pass the official test suites' do
    test_vectors = ::File.read('./ext/blake3/test_vectors/test_vectors.json', mode: 'rb').then do |content|
      ::JSON.parse(content, symbolize_names: true)
    end
    key, context_string, test_cases = test_vectors.values_at(:key, :context_string, :cases)
    input_generator = ::Enumerator.new do |yielder|
      loop do
        yielder << (0..250)
      end
    end.lazy.flat_map(&:lazy).map(&:chr)

    test_cases.each do |test_case|
      digest = described_class.new
      keyed_digest = described_class.new(key: key)
      seeded_digest = described_class.new(key_seed: context_string)
      input_generator.take(test_case[:input_len]).each_slice(1024) do |char_list|
        chunk = char_list.join
        digest << chunk
        keyed_digest << chunk
        seeded_digest << chunk
      end
      expect(digest.hexdigest).to eq(test_case[:hash][0, described_class::DEFAULT_OUTPUT_LENGTH * 2])
      expect(keyed_digest.hexdigest).to eq(test_case[:keyed_hash][0, described_class::DEFAULT_OUTPUT_LENGTH * 2])
      expect(seeded_digest.hexdigest).to eq(test_case[:derive_key][0, described_class::DEFAULT_OUTPUT_LENGTH * 2])
    end
  end
end

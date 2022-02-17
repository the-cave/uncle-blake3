# frozen_string_literal: true

require 'json'

RSpec.describe ::UncleBlake3::Digest do
  it 'pass the official test suites' do
    test_vectors = ::File.read('./ext/blake3/test_vectors/test_vectors.json', mode: 'rb').then do |content|
      ::JSON.parse(content, symbolize_names: true)
    end
    key, context_string, test_cases = test_vectors.values_at(:key, :context_string, :cases)
    gen_input = lambda do |length|
      ::Enumerator.new do |yielder|
        loop do
          yielder << (0..250).each
        end
      end.lazy.flat_map(&:to_a).lazy.map(&:chr).take(length).to_a.join
    end

    test_cases.each do |test_case|
      input = gen_input.call(test_case[:input_len])
      expect(described_class.hexdigest(input)).to eq(test_case[:hash][0, described_class::DEFAULT_OUTPUT_LENGTH * 2])
      expect(described_class.hexdigest(input, key: key)).to eq(test_case[:keyed_hash][0, described_class::DEFAULT_OUTPUT_LENGTH * 2])
      expect(described_class.hexdigest(input, key_seed: context_string)).to eq(test_case[:derive_key][0, described_class::DEFAULT_OUTPUT_LENGTH * 2])
    end
  end
end

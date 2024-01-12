# frozen_string_literal: true

RSpec.describe FractionalIndexing do
  it "has a version number" do
    expect(FractionalIndexing::VERSION).not_to be nil
  end

  describe 'generate_key_between' do
    def test(a, b, exp)
      begin
        act = FractionalIndexing.generate_key_between(a, b)
      rescue FractionalIndexing::Error => e
        act = e.message
      end

      expect(exp).to eq(act)
    end

    it 'returns the expected results' do
      test(nil, nil, 'a0')
      test(nil, 'a0', 'Zz')
      test(nil, 'Zz', 'Zy')
      test('a0', nil, 'a1')
      test('a1', nil, 'a2')
      test('a0', 'a1', 'a0V')
      test('a1', 'a2', 'a1V')
      test('a0V', 'a1', 'a0l')
      test('Zz', 'a0', 'ZzV')
      test('Zz', 'a1', 'a0')
      test(nil, 'Y00', 'Xzzz')
      test('bzz', nil, 'c000')
      test('a0', 'a0V', 'a0G')
      test('a0', 'a0G', 'a08')
      test('b125', 'b129', 'b127')
      test('a0', 'a1V', 'a1')
      test('Zz', 'a01', 'a0')
      test(nil, 'a0V', 'a0')
      test(nil, 'b999', 'b99')
      test(
        nil,
        'A00000000000000000000000000',
        'invalid order key: A00000000000000000000000000'
      )
      test(nil, 'A000000000000000000000000001', 'A000000000000000000000000000V')
      test('zzzzzzzzzzzzzzzzzzzzzzzzzzy', nil, 'zzzzzzzzzzzzzzzzzzzzzzzzzzz')
      test('zzzzzzzzzzzzzzzzzzzzzzzzzzz', nil, 'zzzzzzzzzzzzzzzzzzzzzzzzzzzV')
      test('a00', nil, 'invalid order key: a00')
      test('a00', 'a1', 'invalid order key: a00')
      test('0', '1', 'invalid order key head: 0')
      test('a1', 'a0', 'a1 >= a0')
      test('a0', 'a00V', 'a00G')
    end
  end

  describe 'generate_n_keys_between' do
    def test_n(a, b, n, exp)
      base_10_digits = '0123456789'

      begin
        act = FractionalIndexing.generate_n_keys_between(a, b, n, base_10_digits).join(' ')
      rescue FractionalIndexing::Error => e
        act = e.message
      end

      expect(exp).to eq(act)
    end

    it 'returns the expected results' do
      test_n(nil, nil, 5, 'a0 a1 a2 a3 a4')
      test_n('a4', nil, 10, 'a5 a6 a7 a8 a9 b00 b01 b02 b03 b04')
      test_n(nil, 'a0', 5, 'Z5 Z6 Z7 Z8 Z9')
      test_n(
        'a0',
        'a2',
        20,
        'a01 a02 a03 a035 a04 a05 a06 a07 a08 a09 a1 a11 a12 a13 a14 a15 a16 a17 a18 a19'
      )
    end
  end

  describe 'generate_key_between (base 95)' do
    def test_base_95(a, b, exp)
      base_95_digits = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~'

      begin
        act = FractionalIndexing.generate_key_between(a, b, base_95_digits)
      rescue FractionalIndexing::Error => e
        act = e.message
      end

      expect(exp).to eq(act)
    end

    it 'returns the expected results' do
      test_base_95('a00', 'a01', 'a00P')
      test_base_95('a0/', 'a00', 'a0/P')
      test_base_95(nil, nil, 'a ')
      test_base_95('a ', nil, 'a!')
      test_base_95(nil, 'a ', 'Z~')
      test_base_95('a0 ', 'a0!', 'invalid order key: a0 ')
      test_base_95(
        nil,
        'A                          0',
        'A                          ('
      )
      test_base_95('a~', nil, 'b  ')
      test_base_95('Z~', nil, 'a ')
      test_base_95('b   ', nil, 'invalid order key: b   ')
      test_base_95('a0', 'a0V', 'a0;')
      test_base_95('a  1', 'a  2', 'a  1P')
      test_base_95(
        nil,
        'A                          ',
        'invalid order key: A                          '
      )
    end
  end
end

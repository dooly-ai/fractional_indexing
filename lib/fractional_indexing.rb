# frozen_string_literal: true

# License: CC0 (no rights reserved).

require_relative "fractional_indexing/version"

# This is based on https://observablehq.com/@dgreensp/implementing-fractional-indexing
module FractionalIndexing
  class Error < StandardError; end

  BASE_62_DIGITS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

  module_function

  # `a` may be empty string, `b` is nil or non-empty string.
  # `a < b` lexicographically if `b` is non-nil.
  # no trailing zeros allowed.
  # digits is a string such as '0123456789' for base 10.  Digits must be in
  # ascending character code order!
  def midpoint(a, b, digits)
    zero = digits[0]

    raise Error, "#{a} >= #{b}" if b && a >= b
    raise Error, "trailing zero" if (a && a[-1] == zero) || (b && b[-1] == zero)

    if b
      # remove longest common prefix.  pad `a` with 0s as we
      # go. note that we don't need to pad `b`, because it can't
      # end before `a` while traversing the common prefix.
      n = 0
      while (a[n] || zero) == b[n]
        n += 1
      end
      if n > 0
        return b[0, n] + midpoint(a[n..-1], b[n..-1], digits)
      end
    end

    # first digits (or lack of digit) are different
    digit_a = a && a.size > 0 ? digits.index(a[0]) : 0
    digit_b = b && b.size > 0 ? digits.index(b[0]) : digits.size
    if digit_b - digit_a > 1
      mid_digit = ((digit_a + digit_b) * 0.5).round
      return digits[mid_digit]
    else
      # first digits are consecutive
      if b && b.size > 1
        return b[0]
      else
        # `b` is null or has length 1 (a single digit).
        # the first digit of `a` is the previous digit to `b`,
        # or 9 if `b` is null.
        # given, for example, midpoint('49', '5'), return
        # '4' + midpoint('9', null), which will become
        # '4' + '9' + midpoint('', null), which is '495'
        if b.nil? || b.size == 1
          return digits[digit_a] + midpoint(a[1..-1], nil, digits)
        end
      end
    end
  end

  ##
  # @param [String] int
  def validate_integer(int)
    if int.size != get_integer_length(int[0])
      raise Error, "invalid integer part of order key: #{int}"
    end
  end

  ##
  # @param [String] head
  # @return [Integer]
  def get_integer_length(head)
    if head >= "a" && head <= "z"
      return head.ord - "a".ord + 2
    elsif head >= "A" && head <= "Z"
      return "Z".ord - head.ord + 2
    else
      raise Error, "invalid order key head: #{head}"
    end
  end

  ##
  # @param [String] key
  # @return [String]
  def get_integer_part(key)
    integer_part_length = get_integer_length(key[0])
    raise Error, "invalid order key: #{key}" if integer_part_length > key.size
    return key[0, integer_part_length]
  end

  ##
  # @param [String] key
  # @param [String] digits
  def validate_order_key(key, digits)
    if key == "A" + digits[0] * 26
      raise Error, "invalid order key: #{key}"
    end

    # get_integer_part() will raise if the first character is bad,
    # or the key is too short. we'd call it to check these things
    # even if we didn't need the result
    i = get_integer_part(key)
    f = key[i.size..-1]
    raise Error, "invalid order key: #{key}" if f[-1] == digits[0]
  end

  ##
  # @param [String] x
  # @param [String] digits
  # @return [String, NilClass]
  def increment_integer(x, digits)
    validate_integer(x)
    head, *digs = x.split('')
    carry = true
    i = digs.size - 1
    while carry && i >= 0 do
      d = digits.index(digs[i]) + 1
      if d == digits.size
        digs[i] = digits[0]
      else
        digs[i] = digits[d]
        carry = false
      end
      i -= 1
    end

    if carry
      if head == "Z"
        return "a" + digits[0]
      end
      if head == "z"
        return nil
      end
      h = (head.ord + 1).chr
      if h > "a"
        digs << digits[0]
      else
        digs.pop
      end
      return h + digs.join('')
    else
      return head + digs.join('')
    end
  end

  ##
  # @param [String] x
  # @param [String] digits
  # @return [String, NilClass]
  def decrement_integer(x, digits)
    validate_integer(x)
    head, *digs = x.split('')
    borrow = true
    i = digs.size - 1
    while borrow && i >= 0
      d = digits.index(digs[i]) - 1
      if d == -1
        digs[i] = digits[-1]
      else
        digs[i] = digits[d]
        borrow = false
      end
      i -= 1
    end

    if borrow
      if head == "a"
        return "Z" + digits[-1]
      end
      if head == "A"
        return nil
      end
      h = (head.ord - 1).chr
      if h < "Z"
        digs << digits[-1]
      else
        digs.pop
      end
      return h + digs.join('')
    else
      return head + digs.join('')
    end
  end

  ##
  # `a` is an order key or null (START).
  # `b` is an order key or null (END).
  # `a < b` lexicographically if both are non-null.
  # digits is a string such as '0123456789' for base 10.  Digits must be in
  # ascending character code order!
  #
  # @param [String, NilClass] a
  # @param [String, NilClass] b
  # @param [String] digits (optional)
  # @return [String]
  def generate_key_between(a, b, digits = BASE_62_DIGITS)
    validate_order_key(a, digits) if a
    validate_order_key(b, digits) if b

    if a && b && a >= b
      raise Error, "#{a} >= #{b}"
    end

    if !a
      if !b
        return "a" + digits[0]
      end

      ib = get_integer_part(b)
      fb = b[ib.size..-1]
      if ib == "A" + digits[0] * 26
        return ib + midpoint("", fb, digits)
      end
      if ib < b
        return ib
      end
      res = decrement_integer(ib, digits)
      if !res
        raise Error, "cannot decrement any more"
      end
      return res
    end

    if !b
      ia = get_integer_part(a)
      fa = a[ia.size..-1]
      i = increment_integer(ia, digits)
      return i.nil? ? ia + midpoint(fa, nil, digits) : i
    end

    ia = get_integer_part(a)
    fa = a[ia.size..-1]
    ib = get_integer_part(b)
    fb = b[ib.size..-1]

    if ia == ib
      return ia + midpoint(fa, fb, digits)
    end

    i = increment_integer(ia, digits)
    if i.nil?
      raise Error, "cannot increment any more"
    end
    if i < b
      return i
    end
    ia + midpoint(fa, nil, digits)
  end

  ##
  # same preconditions as generateKeysBetween.
  # n >= 0.
  # Returns an array of n distinct keys in sorted order.
  # If a and b are both null, returns [a0, a1, ...]
  # If one or the other is null, returns consecutive "integer"
  # keys. Otherwise, returns relatively short keys between
  # a and b.
  #
  # @param [String, NilClass] a
  # @param [String, NilClass] b
  # @param [Integer] n
  # @param [String] digits (optional)
  # @return [Array<String>]
  def generate_n_keys_between(a, b, n, digits = BASE_62_DIGITS)
    return [] if n == 0
    return [generate_key_between(a, b, digits)] if n == 1

    if b.nil?
      c = generate_key_between(a, b, digits)
      result = [c]

      (n - 1).times do
        c = generate_key_between(c, b, digits)
        result << c
      end

      return result
    end

    if a.nil?
      c = generate_key_between(a, b, digits)
      result = [c]

      (n - 1).times do
        c = generate_key_between(a, c, digits)
        result << c
      end

      return result.reverse
    end

    mid = n / 2
    c = generate_key_between(a, b, digits)

    return generate_n_keys_between(
      a, c, mid,
      digits
    ) + [c] + generate_n_keys_between(c, b, n - mid - 1, digits)
  end
end

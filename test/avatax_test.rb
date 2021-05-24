# frozen_string_literal: true

require 'test_helper'

class AvataxTest < ActiveSupport::TestCase
  test 'can load Avatax module' do
    assert_kind_of Module, Avatax
  end
end

require 'spec_helper'

describe ConfirmationRequest do
  describe 'defaults' do
    before do
      @user = create_user
      @request = ConfirmationRequest.new(:user => @user)
    end

    it 'should set expired to false by default' do
      @request.save!
      @request.expired.should be_false
    end

    it 'should set confirmed to false be default' do
      @request.save!
      @request.confirmed.should be_false
    end

    it 'should not let expired be nil by default' do
      @request.save!
      @request.expired.should_not be_nil
    end

    it 'should not let expired be nil by default' do
      @request.save!
      @request.confirmed.should_not be_nil
    end

    it 'should set a confirmation code by default' do
      @request.save!
      @request.confirmation_code.should_not be_nil
      @request.confirmation_code.should be_a_kind_of String
    end
  end
end

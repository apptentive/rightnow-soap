require 'spec_helper'

describe RightNow::Objects::Incident do
  describe '#create_incident' do
    context 'with valid parameters' do
      it 'should generate a valid SOAP request body for CREATE'
    end
  end

  describe '#update_incident' do
    context 'with valid paramters' do
      it 'should generate a valid SOAP request body for UPDATE'
    end

    context 'without ID' do
      it 'should raise a validation error'
    end
  end
end

require 'rails_helper'
include ActiveModelSerializers::Adapter

describe JsonApi::PaginationLinks do

  before do
    10.times do
      User.create
    end
    @per_page = 5
  end

  after do
    User.delete_all
  end

  shared_examples_for 'it returns the correct links' do
    specify do
      serialized_object = User.cursor(before: cursor, limit: @per_page)
      options = {
        serialization_context: OpenStruct.new(
          request_url: 'www.example.com',
          query_parameters: {'user_id' => '7'} # arbitrary string
        )
      }

      expected_links = {
        first: 'www.example.com?user_id=7&cursor[before]',
        last: 'www.example.com?user_id=7&cursor[after]',
        next: "www.example.com?user_id=7&cursor[before]=#{cursor - @per_page}",
        prev: "www.example.com?user_id=7&cursor[after]=#{cursor - 1}",
        self: "www.example.com?user_id=7&cursor[before]=#{cursor}"
      }

      response_links = JsonApi::PaginationLinks.new(serialized_object, options).as_json
      expect(response_links).to eq(expected_links)
    end
  end

  context 'cursor is the max id of serialized collection' do
    it_behaves_like 'it returns the correct links' do
      let(:cursor) { 10 }
    end
  end

  context 'cursor is less than the max id of serialized collection' do
    it_behaves_like 'it returns the correct links' do
      let(:cursor) { 18 }
    end
  end
  
  context 'empty serialized object' do
    it 'returns an empty links hash' do
      serialized_object = User.cursor(before: 1)
      options = {
        serialization_context: OpenStruct.new(
          request_url: 'www.example.com',
          query_parameters: {'user_id' => '7'}
        )
      }
      response_links = JsonApi::PaginationLinks.new(serialized_object, options).as_json
      expect(response_links).to eq({})
    end
  end
end
require 'rails_helper'

describe PostsController, type: :controller do

  before do
    10.times do
      Post.create
    end
    @min = Post.first.id
    @max = Post.last.id
  end

  context 'via render' do
    it 'includes pagination headers for paged responses' do
      get :index_with_cursor, { before: @max, limit: 2 }
      expect(response.headers.keys).to include('X-Cursor-After')
      expect(response.headers.keys).to include('X-Cursor-Before')
    end

    it 'does not include paginattion headers for unpaged responses' do
      get :index_without_cursor, { before: @max, limit: 2 }
      expect(response.headers.keys).to include('X-Cursor-After')
      expect(response.headers.keys).to include('X-Cursor-Before')
    end
  end
end

require 'rails_helper'

describe 'finders' do
  shared_examples_for 'the first 5 posts' do
    specify { expect(result).to eq(Post.first(5)) }
  end

  shared_examples_for 'the last 5 posts' do
    specify { expect(result).to eq(Post.last(5))}
  end

  shared_examples_for 'the first 5 posts after 2' do
    specify { expect(result.collect(&:id)).to eq((@min+2 .. @min+6).to_a) }
  end

  shared_examples_for 'the last 5 posts except 2' do
    specify { expect(result.collect(&:id)).to eq((@max-6 .. @max-2).to_a) }
  end

  before do
    @user = User.create
    10.times do
      Post.create(user_id: @user.id)
    end
    @min = Post.first.id
    @max = Post.last.id
  end

  after do
    Post.delete_all
    User.delete_all
  end

  it 'accepts the limit paramter through cursor' do
    expect(Post.cursor(limit: 2).size).to eq(2)
  end

  it 'does not override limit() with cursor option' do
    expect(Post.cursor(limit: 2).limit(8).size).to eq(8)
  end

  it 'returns a PagingCursor::Array' do
    expect(Post.after.to_a.class).to be(PagingCursor::Array)
  end

  context 'on active record' do
    it_behaves_like "the first 5 posts" do
      let(:result) { Post.after.limit(5) }
    end

    it_behaves_like "the last 5 posts" do
      let(:result) { Post.before.limit(5) } 
    end

    it_behaves_like "the first 5 posts after 2" do
      let(:result) { Post.after(@min + 1).limit(5) }
    end

    it_behaves_like "the last 5 posts except 2" do
      let(:result) { Post.before(@max-1).limit(5) }
    end

    it_behaves_like "the first 5 posts" do
      let(:result) { Post.cursor(after: nil).limit(5) }
    end

    it_behaves_like "the last 5 posts" do
      let(:result) { Post.cursor(before: nil).limit(5) }
    end

    it_behaves_like "the first 5 posts after 2" do
      let(:result) { Post.cursor(after: @min + 1).limit(5) }
    end

    it_behaves_like "the last 5 posts except 2" do
      let(:result) { Post.cursor(before: @max-1).limit(5) }
    end
  end

  context 'on relations' do
    it_behaves_like "the first 5 posts" do
      let(:result) { Post.where(user_id: @user.id).after.limit(5) }
    end

    it_behaves_like "the last 5 posts" do
      let(:result) { Post.where(user_id: @user.id).before.limit(5) }
    end

    it_behaves_like "the first 5 posts after 2" do
      let(:result) { Post.where(user_id: @user.id).after(@min + 1).limit(5) }
    end

    it_behaves_like "the last 5 posts except 2" do
      let(:result) { Post.where(user_id: @user.id).before(@max - 1).limit(5) }
    end

    it_behaves_like "the first 5 posts" do
      let(:result) { Post.where(user_id: @user.id).cursor(after: nil).limit(5) }
    end

    it_behaves_like "the last 5 posts" do
      let(:result) { Post.where(user_id: @user.id).cursor(before: nil).limit(5) }
    end

    it_behaves_like "the first 5 posts after 2" do
      let(:result) { Post.where(user_id: @user.id).cursor(after: @min + 1).limit(5) }
    end

    it_behaves_like "the last 5 posts except 2" do
      let(:result) { Post.where(user_id: @user.id).cursor(before: @max-1).limit(5) }
    end
  end

  context 'on associations' do
    it_behaves_like "the first 5 posts" do
      let(:result) { @user.posts.after.limit(5) }
    end

    it_behaves_like "the last 5 posts" do
      let(:result) { @user.posts.before.limit(5) }
    end

    it_behaves_like "the first 5 posts after 2" do
      let(:result) { @user.posts.after(@min + 1).limit(5) }
    end

    it_behaves_like "the last 5 posts except 2" do
      let(:result) { @user.posts.before(@max - 1).limit(5) }
    end

    it_behaves_like "the first 5 posts" do
      let(:result) { @user.posts.cursor(after: nil).limit(5) }
    end

    it_behaves_like "the last 5 posts" do
      let(:result) { @user.posts.cursor(before: nil).limit(5) }
    end

    it_behaves_like "the first 5 posts after 2" do
      let(:result) { @user.posts.cursor(after: @min + 1).limit(5) }
    end

    it_behaves_like "the last 5 posts except 2" do
      let(:result) { @user.posts.cursor(before: @max - 1).limit(5) }
    end
  end
end

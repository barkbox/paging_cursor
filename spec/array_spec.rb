require 'rails_helper'

describe PagingCursor::Array do
  it "adds before and after cursors" do
    a = PagingCursor::Array.new([u1=User.create, u2=User.create])
    expect(a.cursor_before).to eq(u1.id)
    expect(a.cursor_after).to eq(u2.id)
  end

  it "adds correct cursors when array is not sorted" do
    a = PagingCursor::Array.new([u1=User.create, u2=User.create].reverse)
    expect(a.cursor_before).to eq(u1.id)
    expect(a.cursor_after).to eq(u2.id)
  end

  it "adds cursors for non-id primary key columns" do
    a = PagingCursor::Array.new([t1=Tag.create, t2=Tag.create])
    expect(a.cursor_before).to eq(t1.name)
    expect(a.cursor_after).to eq(t2.name)
  end
end

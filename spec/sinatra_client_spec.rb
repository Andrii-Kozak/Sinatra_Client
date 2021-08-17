require 'spec_helper'

RSpec.describe SinatraClient do

  it "has a version number" do
    expect(SinatraClient::VERSION).not_to be nil
  end

  subject { described_class.new }

  describe 'User post endpoints' do
    let!(:user_id) { 1 }

    describe '#get_user_post' do
      let!(:url) { "http://#{ENV['SINATRA_HOST']}:#{ENV['SINATRA_PORT']}/api/v1/users/#{user_id}/posts" }

      context 'when user posts' do
        let(:body) do
          [{
            'id' => 1,
            'body' => 'Beatae et ipsam. Amet placeat eligendi. Rem in sed.',
            'postable_type' => 'User',
            'postable_id' => 1,
            'created_at' => '2021-05-17T15:31:08.171Z',
            'updated_at' => '2021-05-17T15:31:08.171Z'
          }]
        end

        before do
          WebMock.stub_request(:get, url).to_return(status: 200, body: body.to_json)
        end

        it 'GET request returns success' do
          response_body = subject.get_user_posts(user_id)
          expect(response_body).to eq(body)
        end
      end
    end

    describe '#create_post for user' do
      let!(:url) { "http://#{ENV['SINATRA_HOST']}:#{ENV['SINATRA_PORT']}/api/v1/posts" }

      context 'with parameters' do
        let(:parameters) { { body: 'some text' } }
        let(:post_response) { { 'message' => 'Post successfully created' } }

        before do
          WebMock.stub_request(:post, url).to_return(status: 200, body: post_response.to_json)
        end

        it 'returns redirect status' do
          response_body = subject.create_post(parameters)
          expect(response_body).to eq(post_response)
        end
      end
    end

    describe '#delete_post for user' do
      let(:post_id) { 1 }
      let(:post_response) { { 'message' => 'Post successfully destroyed' } }
      let(:url) { "http://#{ENV['SINATRA_HOST']}:#{ENV['SINATRA_PORT']}/api/v1/posts/#{post_id}" }

      before do
        WebMock.stub_request(:delete, url)
               .with(query: hash_excluding({ current_user: user_id }))
               .to_return(status: 200, body: post_response.to_json)
      end

      it 'returns parsed response from sinatra app' do
        response_body = subject.delete_post(post_id)
        expect(response_body).to eq(post_response)
      end
    end
  end

  describe 'Group post endpoints' do
    let!(:group_id) { 1 }
    let!(:url) { "http://#{ENV['SINATRA_HOST']}:#{ENV['SINATRA_PORT']}/api/v1/groups/#{group_id}/posts" }

    describe '#get_group_posts' do
      context 'when user posts' do
        let(:body) do
          [{
            'id' => 1,
            'body' => 'Beatae et ipsam. Amet placeat eligendi. Rem in sed.',
            'postable_type' => 'Group',
            'postable_id' => 1,
            'created_at' => '2021-05-17T15:31:08.171Z',
            'updated_at' => '2021-05-17T15:31:08.171Z'
          }]
        end

        before do
          WebMock.stub_request(:get, url).to_return(status: 200, body: body.to_json)
        end

        it 'GET request returns success' do
          response_body = subject.get_group_posts(group_id)
          expect(response_body).to eq(body)
        end
      end
    end

    describe '#delete_post for group' do
      let(:post_id) { 1 }
      let(:post_response) { { 'message' => 'Post successfully destroyed' } }
      let(:url) { "http://#{ENV['SINATRA_HOST']}:#{ENV['SINATRA_PORT']}/api/v1/posts/#{post_id}" }

      before do
        WebMock.stub_request(:delete, url)
               .with(query: hash_excluding({ current_user: group_id }))
               .to_return(status: 200, body: post_response.to_json)
      end

      it 'returns parsed response from sinatra app' do
        response_body = subject.delete_post(post_id)
        expect(response_body).to eq(post_response)
      end
    end
  end

  describe 'Comment post endpoints' do
    let(:user_id) { 1 }
    let(:post_id) { 1 }
    let(:url) do
      "http://#{ENV['SINATRA_HOST']}:#{ENV['SINATRA_PORT']}/api/v1/posts/#{post_id}/comments"
    end

    describe '#get_user_posts_comment' do
      context 'when posts comments' do
        let(:body) do
          [{
            'body' => 'Soluta pariatur eos eum.',
            'created_at' => '2021-06-07',
            'creator_id' => user_id,
            'id' => 1,
            'post_id' => post_id,
            'updated_at' => '2021-06-07'
          }]
        end

        before do
          WebMock.stub_request(:get, url).to_return(status: 200, body: body.to_json)
        end

        it 'GET request returns success' do
          response_body = subject.get_user_posts_comment(post_id)
          expect(response_body).to eq(body)
        end
      end
    end

    describe '#create_comment_for_post' do
      context 'with parameters' do
        let(:comment_parameters) { { comment: { body: 'some text', creator_id: 1, post_id: '1' } } }
        let(:comment_response) do
          { 'comment' => { 'body' => 'some text',
                           'creator_id' => 1,
                           'id' => 1,
                           'post_id' => '1' } }
        end

        before do
          WebMock.stub_request(:post, url).to_return(status: 200, body: comment_response.to_json)
        end

        it 'returns redirect status' do
          response_body = subject.create_comment_for_post(post_id, comment_parameters)
          expect(response_body).to eq(comment_response)
        end
      end
    end

    describe '#delete_comment' do
      let(:post_id) { 1 }
      let(:comment_id) { 2 }
      let(:url) do
        "http://#{ENV['SINATRA_HOST']}:#{ENV['SINATRA_PORT']}/api/v1/posts/#{post_id}/comments/#{comment_id}"
      end

      before do
        WebMock.stub_request(:delete, url)
               .with(query: hash_excluding({ current_user: comment_id }))
               .to_return(status: 200, body: comment_id.to_json)
      end

      it 'returns parsed response from sinatra app' do
        response_body = subject.delete_comment(post_id, comment_id)
        expect(response_body).to eq(comment_id)
      end
    end

    describe '#get_likers' do
      let(:post_id) { 1 }
      let(:likers_response) { { 'likers_ids' => [6, 20, 1] } }

      let(:url) do
        "http://#{ENV['SINATRA_HOST']}:#{ENV['SINATRA_PORT']}/api/v1/posts/#{post_id}/likers"
      end

      before do
        WebMock.stub_request(:get, url).to_return(status: 200, body: likers_response.to_json)
      end

      it 'returns parsed response from sinatra app' do
        response_body = subject.get_likers(post_id)
        expect(response_body).to eq(likers_response)
      end
    end

    describe '#create_or_delete_like' do
      let(:post_id) { 1 }
      let(:liker_id) { 1 }
      let(:likes_count_response) { { 'likes_count' => 1 } }

      let(:url) do
        "http://#{ENV['SINATRA_HOST']}:#{ENV['SINATRA_PORT']}/api/v1/posts/#{post_id}/toggle_like"
      end

      before do
        WebMock.stub_request(:post, url).to_return(status: 200, body: likes_count_response.to_json)
      end

      it 'returns parsed response from sinatra app' do
        response_body = subject.create_or_delete_like(post_id, liker_id)
        expect(response_body).to eq(likes_count_response)
      end
    end
  end

  describe '#delete_posts_for' do
    let!(:postable_id) { 1 }
    let!(:postable_type) { 'User' }
    let(:response_status) { { 'status' => 'success' } }

    let(:url) do
      "http://#{ENV['SINATRA_HOST']}:#{ENV['SINATRA_PORT']}/api/v1/postable/#{postable_id}/posts?postable_type=#{postable_type}"
    end

    before do
      WebMock.stub_request(:delete, url).to_return(status: 200, body: response_status.to_json)
    end

    it 'returns status from sinatra app' do
      response_body = subject.delete_posts_for(postable_id, postable_type)
      expect(response_body).to eq(response_status)
    end
  end
end

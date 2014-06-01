require 'spec_helper'

if active_record3?
  describe Bullet::Detector::Association, 'has_many' do
    context "post => comments" do
      it "should detect non preload post => comments" do
        Post.all.each do |post|
          post.comments.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Post, :comments)
      end

      it "should detect preload with post => comments" do
        Post.includes(:comments).each do |post|
          post.comments.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect unused preload post => comments" do
        Post.includes(:comments).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Post, :comments)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should not detect unused preload post => comments" do
        Post.all.map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect non preload comment => post with inverse_of" do
        Post.includes(:comments).each do |post|
          post.comments.each do |comment|
            comment.name
            comment.post.name
          end
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end

    context "category => posts => comments" do
      it "should detect non preload category => posts => comments" do
        Category.all.each do |category|
          category.posts.each do |post|
            post.comments.map(&:name)
          end
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Category, :posts)
        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Post, :comments)
      end

      it "should detect preload category => posts, but no post => comments" do
        Category.includes(:posts).each do |category|
          category.posts.each do |post|
            post.comments.map(&:name)
          end
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).not_to be_detecting_unpreloaded_association_for(Category, :posts)
        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Post, :comments)
      end

      it "should detect preload with category => posts => comments" do
        Category.includes({:posts => :comments}).each do |category|
          category.posts.each do |post|
            post.comments.map(&:name)
          end
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect preload with category => posts => comments with posts.id > 0" do
        Category.includes({:posts => :comments}).where('posts.id > 0').each do |category|
          category.posts.each do |post|
            post.comments.map(&:name)
          end
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect unused preload with category => posts => comments" do
        Category.includes({:posts => :comments}).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Post, :comments)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect unused preload with post => commnets, no category => posts" do
        Category.includes({:posts => :comments}).each do |category|
          category.posts.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Post, :comments)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end

    context "category => posts, category => entries" do
      it "should detect non preload with category => [posts, entries]" do
        Category.all.each do |category|
          category.posts.map(&:name)
          category.entries.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Category, :posts)
        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Category, :entries)
      end

      it "should detect preload with category => posts, but not with category => entries" do
        Category.includes(:posts).each do |category|
          category.posts.map(&:name)
          category.entries.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).not_to be_detecting_unpreloaded_association_for(Category, :posts)
        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Category, :entries)
      end

      it "should detect preload with category => [posts, entries]" do
        Category.includes([:posts, :entries]).each do |category|
          category.posts.map(&:name)
          category.entries.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect unused preload with category => [posts, entries]" do
        Category.includes([:posts, :entries]).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Category, :posts)
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Category, :entries)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect unused preload with category => entries, but not with category => posts" do
        Category.includes([:posts, :entries]).each do |category|
          category.posts.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_unused_preload_associations_for(Category, :posts)
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Category, :entries)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end

    context "post => comment" do
      it "should detect unused preload with post => comments" do
        Post.includes(:comments).each do |post|
          post.comments.first.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_unused_preload_associations_for(Post, :comments)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect preload with post => commnets" do
        Post.first.comments.map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end

    context "category => posts => writer" do
      it "should not detect unused preload associations" do
        category = Category.includes({:posts => :writer}).order("id DESC").find_by_name('first')
        category.posts.map do |post|
          post.name
          post.writer.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_unused_preload_associations_for(Category, :posts)
        expect(Bullet::Detector::Association).not_to be_unused_preload_associations_for(Post, :writer)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end

    context "scope for_category_name" do
      it "should detect preload with post => category" do
        Post.in_category_name('first').each do |post|
          post.category.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should not be unused preload post => category" do
        Post.in_category_name('first').all.map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end

    context "scope preload_comments" do
      it "should detect preload post => comments with scope" do
        Post.preload_comments.each do |post|
          post.comments.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect unused preload with scope" do
        Post.preload_comments.map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Post, :comments)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end
  end

  describe Bullet::Detector::Association, 'belongs_to' do
    context "comment => post" do
      it "should detect non preload with comment => post" do
        Comment.all.each do |comment|
          comment.post.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Comment, :post)
      end

      it "should detect preload with one comment => post" do
        Comment.first.post.name
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should dtect preload with comment => post" do
        Comment.includes(:post).each do |comment|
          comment.post.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should not detect preload with comment => post" do
        Comment.all.map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect unused preload with comments => post" do
        Comment.includes(:post).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Comment, :post)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end

    context "comment => post => category" do
      it "should detect non preload association with comment => post" do
        Comment.all.each do |comment|
          comment.post.category.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Comment, :post)
      end

      it "should detect non preload association with post => category" do
        Comment.includes(:post).each do |comment|
          comment.post.category.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Post, :category)
      end

      it "should not detect unpreload association" do
        Comment.includes(:post => :category).each do |comment|
          comment.post.category.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end

    context "comment => author, post => writer" do
      # this happens because the post isn't a possible object even though the writer is access through the post
      # which leads to an 1+N queries
      it "should detect non preloaded writer" do
        Comment.includes([:author, :post]).where(["base_users.id = ?", BaseUser.first]).each do |comment|
          comment.post.writer.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Post, :writer)
      end

      it "should detect unused preload with comment => author" do
        Comment.includes([:author, {:post => :writer}]).where(["base_users.id = ?", BaseUser.first]).each do |comment|
          comment.post.writer.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      # To flyerhzm: This does not detect that newspaper is unpreloaded. The association is
      # not within possible objects, and thus cannot be detected as unpreloaded
      it "should detect non preloading with writer => newspaper" do
        Comment.all(:include => {:post => :writer}, :conditions => "posts.name like '%first%'").each do |comment|
          comment.post.writer.newspaper.name
        end
        #Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        #Bullet::Detector::Association.should_not be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Writer, :newspaper)
      end

      # when we attempt to access category, there is an infinite overflow because load_target is hijacked leading to
      # a repeating loop of calls in this test
      it "should not raise a stack error from posts to category" do
        expect {
          Comment.includes({:post => :category}).each do |com|
            com.post.category
          end
        }.not_to raise_error
      end
    end
  end

  describe Bullet::Detector::Association, 'has_and_belongs_to_many' do
    context "students <=> teachers" do
      it "should detect non preload associations" do
        Student.all.each do |student|
          student.teachers.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Student, :teachers)
      end

      it "should detect preload associations" do
        Student.includes(:teachers).each do |student|
          student.teachers.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect unused preload associations" do
        Student.includes(:teachers).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Student, :teachers)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect no unused preload associations" do
        Student.all.map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end
  end

  describe Bullet::Detector::Association, 'has_many :through' do
    context "firm => clients" do
      it "should detect non preload associations" do
        Firm.all.each do |firm|
          firm.clients.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Firm, :clients)
      end

      it "should detect preload associations" do
        Firm.includes(:clients).each do |firm|
          firm.clients.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should not detect preload associations" do
        Firm.all.map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect unused preload associations" do
        Firm.includes(:clients).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Firm, :clients)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end
  end

  describe Bullet::Detector::Association, "has_one" do
    context "company => address" do
      it "should detect non preload association" do
        Company.all.each do |company|
          company.address.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Company, :address)
      end

      it "should detect preload association" do
        Company.includes(:address).each do |company|
          company.address.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should not detect preload association" do
        Company.all.map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect unused preload association" do
        Company.includes(:address).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Company, :address)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end
  end

  describe Bullet::Detector::Association, "call one association that in possible objects" do
    it "should not detect preload association" do
      Post.all
      Post.first.comments.map(&:name)
      Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
      expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

      expect(Bullet::Detector::Association).to be_completely_preloading_associations
    end
  end

  describe Bullet::Detector::Association, "STI" do
    context "page => author" do
      it "should detect non preload associations" do
        Page.all.each do |page|
          page.author.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Page, :author)
      end

      it "should detect preload associations" do
        Page.includes(:author).each do |page|
          page.author.name
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should detect unused preload associations" do
        Page.includes(:author).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Page, :author)

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end

      it "should not detect preload associations" do
        Page.all.map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
      end
    end

    context "disable n plus one query" do
      before { Bullet.n_plus_one_query_enable = false }
      after { Bullet.n_plus_one_query_enable = true }

      it "should not detect n plus one query" do
        Post.all.each do |post|
          post.comments.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations

        expect(Bullet::Detector::Association).not_to be_detecting_unpreloaded_association_for(Post, :comments)
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations
      end

      it "should still detect unused eager loading" do
        Post.includes(:comments).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Post, :comments)
      end
    end

    context "disable unused eager loading" do
      before { Bullet.unused_eager_loading_enable = false }
      after { Bullet.unused_eager_loading_enable = true }

      it "should not detect unused eager loading" do
        Post.includes(:comments).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations
      end

      it "should still detect n plus one query" do
        Post.all.each do |post|
          post.comments.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Post, :comments)
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations
      end
    end

    context "whitelist n plus one query" do
      before { Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "Post", :association => :comments }
      after { Bullet.reset_whitelist }

      it "should not detect n plus one query" do
        Post.all.each do |post|
          post.comments.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations

        expect(Bullet::Detector::Association).not_to be_detecting_unpreloaded_association_for(Post, :comments)
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations
      end

      it "should still detect unused eager loading" do
        Post.includes(:comments).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
        expect(Bullet::Detector::Association).to be_unused_preload_associations_for(Post, :comments)
      end
    end

    context "whitelist unused eager loading" do
      before { Bullet.add_whitelist :type => :unused_eager_loading, :class_name => "Post", :association => :comments }
      after { Bullet.reset_whitelist }

      it "should not detect unused eager loading" do
        Post.includes(:comments).map(&:name)
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations

        expect(Bullet::Detector::Association).to be_completely_preloading_associations
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations
      end

      it "should still detect n plus one query" do
        Post.all.each do |post|
          post.comments.map(&:name)
        end
        Bullet::Detector::UnusedEagerLoading.check_unused_preload_associations

        expect(Bullet::Detector::Association).to be_detecting_unpreloaded_association_for(Post, :comments)
        expect(Bullet::Detector::Association).not_to be_has_unused_preload_associations
      end
    end
  end
end

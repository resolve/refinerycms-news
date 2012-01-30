module Refinery
  module News
    class Item < ActiveRecord::Base

      translates :title, :body

      attr_accessor :locale # to hold temporarily

      alias_attribute :content, :body
      validates :title, :content, :publish_date, :presence => true

      has_friendly_id :title, :use_slug => true

      acts_as_indexed :fields => [:title, :body]

      default_scope :order => "publish_date DESC"

      scope :by_archive, lambda { |archive_date|
        where(['publish_date between ? and ?', archive_date.beginning_of_month, archive_date.end_of_month])
      }

      scope :by_year, lambda { |archive_year|
        where(['publish_date between ? and ?', archive_year.beginning_of_year, archive_year.end_of_year])
      }

      scope :all_previous, lambda { where(['publish_date <= ?', Time.now.beginning_of_month]) }

      scope :previous, lambda { |i| where("publish_date < ?", i.publish_date).limit(1) }

      # If you're using a named scope that includes a changing variable you need to wrap it in a lambda
      # This avoids the query being cached thus becoming unaffected by changes (i.e. Time.now is constant)
      scope :not_expired, lambda {
        news_items = Arel::Table.new(self.table_name)
        where(news_items[:expiration_date].eq(nil).or(news_items[:expiration_date].gt(Time.now)))
      }
      scope :published, lambda {
        not_expired.where("publish_date < ?", Time.now)
      }
      scope :latest, lambda { |*l_params|
        published.limit( l_params.first || 10)
      }

      scope :live, lambda { not_expired.where( "publish_date <= ?", Time.now) }

      # rejects any page that has not been translated to the current locale.
      scope :translated, lambda {
        pages = Arel::Table.new(self.table_name)
        translations = Arel::Table.new(self.translations_table_name)

        includes(:translations).where(
          translations[:locale].eq(Globalize.locale)).where(pages[:id].eq(translations[:refinery_news_item_id]))
      }

      def not_published? # has the published date not yet arrived?
        publish_date > Time.now
      end

      def next
        self.class.next(self).first
      end

      def prev
        self.class.previous(self).first
      end

      class << self
        def next(current_record)
          self.send(:with_exclusive_scope) do
            where("publish_date > ?", current_record.publish_date).order("publish_date ASC")
          end
        end

        def teasers_enabled?
          Refinery::Setting.find_or_set(:teasers_enabled, true, :scoping => 'blog')
        end

        def teaser_enabled_toggle!
          currently = Refinery::Setting.find_or_set(:teasers_enabled, true, :scoping => 'blog')
          Refinery::Setting.set(:teasers_enabled, :value => !currently, :scoping => 'blog')
        end
      end

    end
  end
end
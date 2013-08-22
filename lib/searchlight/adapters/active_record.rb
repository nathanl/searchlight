module Searchlight
  module Adapters
    module ActiveRecord

      def search_on(target)
        super
        extend Search       if is_active_record?(target)
        convert_to_relation if is_active_record_class?(target)
      end

      module Search
        def searches(*attribute_names)
          super

          # Ensure this class only adds one search module to the ancestors chain
          if @ar_searches_module.nil?
            @ar_searches_module = Named::Module.new("SearchlightActiveRecordSearches(#{self})")
            include @ar_searches_module
          end

          eval_string = attribute_names.map { |attribute_name|
            model_class = model_class_for(search_target)
            if model_has_db_attribute?(attribute_name.to_s)

              <<-UNICORN_BILE
              def search_#{attribute_name}
                search.where('#{attribute_name}' => public_send("#{attribute_name}"))
              end
              UNICORN_BILE
            else
              <<-MERMAID_TEARS
              def search_#{attribute_name}
                raise Searchlight::Adapters::ActiveRecord::UndefinedColumn,
                "Class `#{model_class}` has no column `#{attribute_name}`; please define `search_#{attribute_name}` on `\#{self.class}` to clarify what you intend to search for"
              end
              MERMAID_TEARS
            end

          }.join

          @ar_searches_module.module_eval(eval_string, __FILE__, __LINE__)
        end

        # The idea here is to provide a means to allow users to bypass the check if it causes problems (e.g. during
        # `rake assets:precompile` if the DB has yet to be created). To bypass this, a user could monkey patch as
        # follows:
        #
        #     module Searchlight::Adapters::ActiveRecord::Search
        #       def model_has_db_attribute?(attribute_name)
        #         model_class_for(search_target).columns_hash.keys.include?(attribute_name)
        #       rescue StandardError
        #         true
        #       end
        #     end
        #
        # Alternatively, they could monkey-patch Searchlight::Adapters::ActiveRecord::Search::model_has_db_attribute
        # to simply always return true, though they would then not get the benefit of the improved error messaging.
        #
        def model_has_db_attribute?(attribute_name)
          model_class_for(search_target).columns_hash.keys.include?(attribute_name)
        end
      end

      protected

      def is_active_record?(target)
         is_active_record_class?(target) || is_active_record_relation?(target)
      end

      def is_active_record_class?(target)
        target.is_a?(Class) && target.ancestors.include?(::ActiveRecord::Base)
      end

      def is_active_record_relation?(target)
        target.is_a?(::ActiveRecord::Relation)
      end

      # Ensure that searches without options still return enumerable results
      def convert_to_relation
        self.search_target = (active_record_version >= 4) ? search_target.all : search_target.scoped
      end

      def model_class_for(target)
        is_active_record_class?(target) ? target : target.engine
      end

      def active_record_version
        ::ActiveRecord::VERSION::MAJOR.to_i
      end

      UndefinedColumn = Class.new(StandardError)
    end
  end
end

Searchlight::Search.extend(Searchlight::Adapters::ActiveRecord)

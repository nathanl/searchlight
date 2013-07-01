module Searchlight
  module Adapters
    module Mongoid

      def search_on(target)
        super
        extend Search if mongoid?(target)
      end

      module Search

        def searches(*attributes_names)
          super

          attributes_names.map do |attribute_name|
            method_name = "search_#{attribute_name}"
            if field?(attribute_name)
              define_method method_name do
                search.where(attribute_name.to_s => public_send(attribute_name))
              end
            else
              define_method method_name do
                raise Searchlight::Adapters::Mongoid::UndefinedColumn,
                "Class `#{self.class.model_class}` has no field `#{attribute_name}`; please define `search_#{attribute_name}` on `#{self.class}` to clarify what you intend to search for"
              end
            end
          end
        end

        def field?(attributes_name)
          model_class.fields.has_key? attributes_name.to_s
        end

        def model_class
          search_target.is_a?(::Mongoid::Criteria) ? search_target.klass : search_target
        end

      end

      protected

      def mongoid?(target)
        mongoid_document?(target) || mongoid_criteria?(target)
      end

      def mongoid_document?(target)
        defined?(::Mongoid::Document) && target.include?(::Mongoid::Document)
      end

      def mongoid_criteria?(target)
        defined?(::Mongoid::Criteria) && target.is_a?(::Mongoid::Criteria)
      end

      UndefinedColumn = Class.new(StandardError)

    end
  end
end

Searchlight::Search.extend(Searchlight::Adapters::Mongoid)

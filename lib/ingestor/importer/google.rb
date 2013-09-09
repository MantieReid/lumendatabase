module Ingestor
  module Importer
    class Google

      def self.handles?(file_paths)
        file_paths && file_paths.split(',').any? do |file|
          File.open(file) { |f| f.grep(/^field_form_version:/) }.present?
        end
      end

      def initialize(file_paths)
        @file_paths = file_paths
      end

      def works
        parse_works.map do |field_group_index, data|
          Work.new(
            description: data[:description],
            infringing_urls_attributes: data[:infringing_urls].collect{|url| {url: url}},
            copyrighted_urls_attributes: data[:copyrighted_urls].collect{|url| {url: url}}
          )
        end
      end

      def file_uploads
        [] # TODO
      end

      private

      attr_reader :file_paths

      def parse_works
        works = {}

        if original_file = find_original_file
          contents = File.read(original_file)

          field_groups = FindFieldGroups.new(contents).find

          field_groups.each do |field_group, field_group_content|
            parser = FieldGroupParser.new(field_group, field_group_content)

            works[field_group] ||= {}
            works[field_group][:description] = parser.description
            works[field_group][:copyrighted_urls] = parser.copyrighted_urls
            works[field_group][:infringing_urls] = parser.infringing_urls
          end
        end

        works
      end

      def find_original_file
        file_paths && file_paths.split(',').find do |file|
          # TODO: logic might change
          file.match(/.+\.txt\Z/)
        end
      end

    end
  end
end
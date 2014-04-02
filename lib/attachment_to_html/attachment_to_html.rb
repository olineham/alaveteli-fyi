require 'html'
require 'view'

Dir[File.dirname(__FILE__) + '/adapters/*.rb'].each do |file|
    require file
end

module AttachmentToHTML
    extend self

    def to_html(attachment, opts = {})
        adapter = adapter_for(attachment).new(attachment, opts)

        unless adapter.success?
          adapter = fallback_adapter_for(attachment).new(attachment, opts)
        end

        view = View.new(adapter)
        view.wrapper = 'wrapper_google_embed' if adapter.is_a?(Adapters::GoogleDocsViewer)

        view.render
    end

    private

    def adapter_for(attachment)
        case attachment.content_type
        when 'text/plain' then Adapters::Text
        when 'application/pdf' then Adapters::PDF
        when 'application/rtf' then Adapters::RTF
        else
            fallback_adapter_for(attachment)
        end
    end

    def fallback_adapter_for(attachment)
        if attachment.has_google_docs_viewer?
            Adapters::GoogleDocsViewer
        else
            Adapters::CouldNotConvert
        end
    end
end

class StyleFileImporter < Sass::Importers::Filesystem
  private

  def _find(dir, name, options)
    full_filename, syntax = Sass::Util.destructure(find_real_file(dir, name, options))
    return unless full_filename && File.readable?(full_filename)

    # TODO: this preserves historical behavior, but it's possible
    # :filename should be either normalized to the native format
    # or consistently URI-format.
    full_filename = full_filename.tr("\\", "/") if Sass::Util.windows?

    source = File.read(full_filename)

    if is_style_path = dir == (options[:issue].path/'styles').to_s
      source = %{article[data-page="#{name == 'cover' ? 'index' : name}"]{#{source}}}
    end

    options[:syntax] = syntax
    options[:filename] = full_filename
    options[:importer] = self

    Sass::Engine.new(source, options)
  end
end

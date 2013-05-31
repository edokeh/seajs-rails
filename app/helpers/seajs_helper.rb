module SeajsHelper
  # generate seajs.use()
  def seajs_use(*modules)
    seajs_config = Rails.application.config.seajs

    if seajs_config.compiled?
      modules.map! { |m| seajs_config.family + '/' + m }
    else
      modules.map! { |m| '/assets/' + m }
    end

    html = <<-html
    <script>
    seajs.use(#{modules.to_s})
    </script>
    html

    html.html_safe
  end

  # include seajs script and map config
  def seajs_tag
    seajs_config = Rails.application.config.seajs

    html = <<-html
      <script src="/assets/sea-modules/#{seajs_config.seajs_path}"></script>
      <script>
      seajs.config({
        map: #{seajs_config.map_json || '[]'}
      })
      </script>
    html

    html.html_safe
  end
end

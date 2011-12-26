module ApplicationHelper
  def title
    base_title = "Ruby on Rails microblogr App"
    
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  def logo
  image_tag("twitter.png", alt: "Twitter", class: "round",width: 200,height: 55 )
  end
end

module ApplicationHelper
  def title
    base_title = "Ruby on Rails Micro-blogging App"
    
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  def logo
  image_tag("twitter.png", alt: "Twitter", class: "round",width: 190,height: 40 )
  end
end

require "mechanize"
require "date"
require "json"
require "pry"

agent = Mechanize.new
page = agent.get("http://pitchfork.com/reviews/albums/")

review_links = page.links_with(href: %r{^/reviews/albums/\w+})

review_links = review_links.reject do |link|
  link.href =~ /popular/ || link.href =~ /page/
end

review_links = review_links[0...4]

reviews = review_links.map do |link|
  review = link.click
  artist = review.search(".artists a")[0].text
  album = review.search(".review-title")[0].text
  label = review.search(".labels-list__item")[0].text
  year = review.search(".year")[0].text
  reviewer = review.search(".authors a").text
  review_date = Date.parse(review.search(".pub-date").attribute("datetime").value)
  score = review.search(".score").text.to_f
  {
    artist: artist,
    album: album,
    label: label,
    year: year,
    reviewer: reviewer,
    review_date: review_date,
    score: score
  }
end

data = JSON.pretty_generate(reviews)

File.write("data.json", data)

Rails.application.routes.draw do
  mount Biovision::Comment::Engine => "/biovision-comment"
end

class ToppagesController < ApplicationController
  def index
    render layout: false #application.html.erbを適用したくない
  end
end

class SearchController < ApplicationController
  def index
    q = params.fetch(:q, "")

    if !turbo_frame_request? && q.length < 3
      return redirect_back(fallback_location: root_path, alert: "Please, enter at least 3 characters")
    end

    artists = Artist.search(q).limit(10)
    albums = Album.search(q).limit(10)
    tracks = Track.search(q).limit(10)

    if turbo_frame_request?
      render partial: "preview", locals: {artists:, albums:, tracks:}
    else
      render action: :index, locals: {artists:, albums:, tracks:}
    end
  end
end

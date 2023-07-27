class Artists::TracksController < ApplicationController
  TRACKS_PER_PAGE = 25

  def index
    tracks = artist_resource.tracks.ordered.limit(TRACKS_PER_PAGE)
    render action: :index, locals: {artist: artist_resource, tracks:}
  end

  private

  def artist_resource
    @artist_resource ||= Artist.find(params[:artist_id])
  end
end

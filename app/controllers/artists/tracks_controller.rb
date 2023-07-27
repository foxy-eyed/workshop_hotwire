class Artists::TracksController < ApplicationController
  TRACKS_PER_PAGE = 25

  def index
    tracks = artist_resource.tracks.ordered.limit(pagination_params[:limit]).offset(pagination_params[:offset])

    if turbo_frame_request?
      render partial: "list", locals: {artist: artist_resource, tracks:, **pagination_params}
    else
      render action: :index, locals: {artist: artist_resource, tracks:, **pagination_params}
    end
  end

  private

  def artist_resource
    @artist_resource ||= Artist.find(params[:artist_id])
  end

  def pagination_params
    @pagination_params ||= begin
      page = params.fetch(:page, 0).to_i
      limit = params.fetch(:limit, TRACKS_PER_PAGE).to_i
      offset = limit * page
      total_pages = (1.0 * artist_resource.tracks.count / limit).ceil
      next_page = (page < total_pages) ? page + 1 : nil

      {current_page: page, limit:, offset:, next_page:, total_pages:}
    end
  end
end

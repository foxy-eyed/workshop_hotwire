class ArtistsController < ApplicationController
  TRACKS_PER_PAGE = 5
  MAX_TRACKS = 10

  def show
    artist = Artist.find(params[:id])
    albums = selected_albums(artist.albums, params[:album_type]).with_attached_cover.preload(:artist)

    cursor = params.fetch(:cursor, 0).to_i
    next_cursor = (cursor + TRACKS_PER_PAGE >= MAX_TRACKS) ? nil : cursor + TRACKS_PER_PAGE

    tracks = artist.tracks.popularity_ordered.limit(TRACKS_PER_PAGE).offset(cursor)

    case turbo_frame_request_id
    when /\Adiscography_artist_\d+\z/
      render partial: "discography", locals: {artist:, albums:}
    when /\Atracks_\d+_artist_\d+\z/
      render partial: "popular_tracks", locals: {artist:, tracks:, cursor:, next_cursor:}
    else
      render action: :show, locals: {artist:, albums:, tracks:, cursor:, next_cursor:}
    end
  end

  private

  def selected_albums(albums, album_type)
    return albums.lp if album_type.blank?

    return albums.lp unless Album.kinds.key?(album_type)

    albums.where(kind: album_type)
  end
end

class RecipesController < ApplicationController
  def index
    begin
      a = Recipe.find params[:id]
      author = a.author
      render json: {
          title: a.title,
          description: a.description,
          ingredients: a.ingredients,
          directions: a.directions,
          prep_time_min: a.prep_time_min,
          cook_time_min: a.cook_time_min,
          servings: a.servings,
          tags: a.tags,
          author: {
            name: author.name,
            url: author.url
          },
          source_url: a.source_url
        }, status: :ok
    rescue => exception
      render json: { message: "Not found" }, status: :not_found
    end
  end

  def list
    indexes = Recipe.all.map { |r| {id: r.id, title: r.title} }
    render json: indexes
  end

  def search
    if search_params.present?
      keyword = search_params[:keyword]
      sql = <<-SQL
        SELECT
          id,
          title
        FROM recipes
        WHERE title like '%#{keyword}%'
          or array_to_string(ingredients, ', ') like '%#{keyword}%'
          or array_to_string(tags, ', ') like '%#{keyword}%'
        GROUP BY 1, 2
      SQL
    else
      sql = <<-SQL
        SELECT
          id,
          title
        FROM recipes
      SQL
    end

    results = ActiveRecord::Base.connection.query(sql)
    indexes = results.map { |r| {id: r[0], title: r[1]} }
    render json: indexes
  end

  def update
    recipe = Recipe.find(update_params.id)
    if recipe.nil?
      render json: { message: "Not found" }, status: :not_found
    else
      recipe.update(update_params.servings)
      render json: { message: "Successfully updated servings" }, status: :ok
    end
  end

  private
  def update_params
    params.permit(:id, :servings)
  end

  def search_params
    params.permit(:keyword)
  end
end

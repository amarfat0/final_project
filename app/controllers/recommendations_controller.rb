class RecommendationsController < ApplicationController
  before_action :current_user_must_be_recommendation_user, :only => [:edit, :update, :destroy]

  def current_user_must_be_recommendation_user
    recommendation = Recommendation.find(params[:id])

    unless current_user == recommendation.user
      redirect_to :back, :alert => "You are not authorized for that."
    end
  end

  def index
    @q = current_user.recommendations.ransack(params[:q])
      @recommendations = @q.result(:distinct => true).includes(:user, :destination).page(params[:page]).per(10)

    render("recommendations/index.html.erb")
  end

  def show
    @recommendation = Recommendation.find(params[:id])

    render("recommendations/show.html.erb")
  end

  def new
    @recommendation = Recommendation.new

    render("recommendations/new.html.erb")
  end

  def create
    @recommendation = Recommendation.new

    @recommendation.user_id = params[:user_id]
    @recommendation.destination_id = params[:destination_id]

    save_status = @recommendation.save

    if save_status == true
      referer = URI(request.referer).path

      case referer
      when "/recommendations/new", "/create_recommendation"
        redirect_to("/recommendations")
      else
        redirect_back(:fallback_location => "/", :notice => "Recommendation created successfully.")
      end
    else
      render("recommendations/new.html.erb")
    end
  end

  def edit
    @recommendation = Recommendation.find(params[:id])

    render("recommendations/edit.html.erb")
  end

  def update
    @recommendation = Recommendation.find(params[:id])
    @recommendation.destination_id = params[:destination_id]

    save_status = @recommendation.save

    if save_status == true
      referer = URI(request.referer).path

      case referer
      when "/recommendations/#{@recommendation.id}/edit", "/update_recommendation"
        redirect_to("/recommendations/#{@recommendation.id}", :notice => "Recommendation updated successfully.")
      else
        redirect_back(:fallback_location => "/", :notice => "Recommendation updated successfully.")
      end
    else
      render("recommendations/edit.html.erb")
    end
  end

  def destroy
    @recommendation = Recommendation.find(params[:id])

    @recommendation.destroy

    if URI(request.referer).path == "/recommendations/#{@recommendation.id}"
      redirect_to("/", :notice => "Recommendation deleted.")
    else
      redirect_back(:fallback_location => "/", :notice => "Recommendation deleted.")
    end
  end
end

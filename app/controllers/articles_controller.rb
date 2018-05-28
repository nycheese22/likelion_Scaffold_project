class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def new
  end

  def show
  end

  def index
  end

  def edit
  end
  
  def create
    binding.pry
    @article = Article.new(aritcle_params)
    # @article.title = params[:title]
    # @article.title = params[:content]
    @aritcle.save
    redirect_to @article
  end

  def destroy
  end
  
  private
    def set_article
      @article = Article.find(params[:id])
    end
    
    def article_params
      params.require(:article).permit(:title, :content)
    end
end

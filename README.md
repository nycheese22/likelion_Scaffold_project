##  Scaffold
1. scaffold는 '발판, 기반이 되는 구조물'이라는 뜻입니다.
2. `rails g scaffold Note title:string content:text`
	* 위 코드를 치면 CRUD로 구성된 게시판이 만들어집니다.
	* 일종의 튜토리얼 코드입니다.(rails 스러운 코드)
	* 우리가 배웠던 코드와 조금 다릅니다.(json이라든지, 이상한 부분이 많습니다.)
3. 이전에 만들었던 notes에서 new.html.erb와 edit.html.erb를 보면 비슷한 코드가 중복되어있는 것을 볼 수 있습니다. **컴퓨터 세계에서 중복은 좋지 않습니다.** 그래서 잘 만들어진 코드 scaffold에서는 form 형태로 따로 만들어져있습니다. 일단은 그렇다고만 알아둡시다.
4. 라우팅을 보는 법(scaffold는 전에 만들었던 것과 다릅니다)
	4. `rails routes`를 치면 라우팅 정보를 알 수 있습니다.
	5. `prefix`는 지름길(helper_path)같은 의미로 동적 링크를 생성하거나 redirection을 이용할 때 유용합니다.
	6. scaffold에는 routes.rb가 한 줄로 표현이 되어 있습니다. (`resources :notes`)

### Scaffold에서 Params의 이해

1. scaffold를 뜯어보기 위해서 새로 Article이라는 model과 controller를 만듭니다. 
6. `rails g model Article title:string content:text`
7. `rails db:migrate`
8. `rails g controller Ariticles new show index edit`
9. routes.rb에서 `resource :notes`는 주석처리(`#`)하고 `resources :articles`를 친 후, 터미널에 `rails routes`를 치면 아까 scaffold처럼 나옵니다.
10. ariticles_controller.rb에 create를 추가합니다.
```ruby
  def create
    debugger
    @article = Article.new
    @article.title = params[:title]
    @article.title = params[:content]
    @aritcle.save
    redirect_to articles_url #path or url(in yoursite/rails/info)
  end
```
11. 그리고 전에 했던 코드의 구조를 보면 show나 destroy나 update, edit 등 똑같은 코드가 들어가는 것을 볼 수 있는데 바로 지정된 데이터를 보여줄 수 있는 `@article = Article.find(params[:id])`라는 코드입니다. 이 중복을 없애주기 위해서 따로 set_article이라는 Action으로 지정해주고, `before_action :set_article, only: [:show, :edit, :update, :destroy]`을 적어줘서 이 코드가 show, edit, update, destroy에만 적용이 되도록 합니다. set_article의 경우, 컨트롤러 이외에 어떤 곳에서 호출하는 경우가 없기 때문에 private을 줘서 다른 곳에서 호출할 경우 에러가 나오도록 하는 역할을 해줍니다.  private이라고 치면 그 밑에는 모두 private 이라고 처리합니다.
```ruby
	private #접근제한자
		def set_article
		  @article = Article.find(params[:id])
	    end
```
12. views/articles/new.html.erb에 코드를 추가합니다.
```ruby
<h1>Articles#new</h1>
<p>Find me in app/views/articles/new.html.erb</p>
<form action='/articles' method='POST'>
    <input type='hidden' name='authenticity_token' value="<%= form_authenticity_token %>"></input><br>
    <input type='text' name='title'></input><br>
    <input type='text' name='content'></input><br>
    <input type='submit'></input>
</form>
```
13. 서버를 실행시킨 후, new.html.erb로 들어가서 입력하면 controller의 create에서 썼던 debugger가 작동하여 중지되고, 터미널에 입력할 수 있도록 나오게 됩니다. 
14. `params`를 쳐보면 우리가 new.html.erb에서 쳤던 게 나오게 되는데 보기가 힘드니 gemfile에서 	보기 편하게 해주는 gem을 설치합시다. 
15. gemfile에서 `gem 'pry-rails'`를 설치합니다.
16. `debugger`대신 `binding.pry`를 써줍니다.
17. 이제 아까처럼 서버를 실행시키고 new.html.erb에 입력하고 콘솔창에 `params`를 쳐보면 아까보다는 구별하기 쉽게 나옵니다. 
18. `params.require(:article)`을 치면 우리가 쳤었던 title과 content가 나오게 됩니다. 
19. `params.require(:article).permit(:title, :content)`를 치면 permitted에 true가 뜹니다. 이는 article에서 원하는 속성들만 노출시킬 수 있도록 해주는 것입니다. 즉, 여기서는 article 안에서 title, content만 쓰고 싶다는 말입니다.
20. `rails c --sandbox`(sandbox 모드로 들어가면 실제로 저장되지 않습니다. 그래서 exit을 했을 때 rollback이라고 나오게 됩니다.)
21. articles_controller.rb에서 `Article.create!(title: 'aa', content: 'bb')`는 `@article = Article.new(title: 'aa', content : 'bb')`, `@article.save`와 같습니다. 하지만 이것은 aa와 bb라는 것을 저장하는 것이고, 사용자의 데이터를 받으려면 params를 써야합니다. 이 때 아까 썼던 `params.require(:article).permit(:title, :content)`를 써주면 됩니다. 그래서 중간에 썼던 `@article.title = params[:title]`와`@article.title = params[:content]`가 `@article = Article.new(aritcle_params)`와 같게 됩니다. 
22. 원래 `redirect_to 'articles/#{@article.id}'`로 썼었는데 이는 helper path를 사용한 `article_url(@article.id)`과 같습니다. 그러나 rails가 helper path는 HTTP GET method에서만 쓰이는 알고 너무 똑똑해서 @article만 써도 알 수 있도록 해놓았습니다.  
23. articles_controller.rb에서 아래의 코드를 변경 & 추가합니다.
```ruby
  def create
    binding.pry
    @article = Article.new(aritcle_params) #두 개의 코드가 하나로 변경
    @aritcle.save
    redirect_to @article #그 article로 가도록 변경
  end

   def article_params #위 코드에서 인자로 들어간다
     params.require(:article).permit(:title, :content)
   end	
```

### Helper

1. 이제 쉽게 만들 수 있는 helper를 알아보겠습니다. **helper를 이용하면 보안성이 좋고, 명시적이고 시멘틱한 HTML 코드를 쉽게 생성할 수 있습니다.** 예를 들어, 몇 줄의 ruby 코드를 작성하면 HTML 코드가 생성되는데 class나 id, label, name, 토큰 등 여러 가지 기능을 갖춘 HTML 코드가 생성됩니다. view helper는 기본적으로 ruby 코드입니다. 먼저 form_for()라는 메소드를 사용해봅시다.
```ruby
#저는 오류가 나서 첫 줄을 form_for Article.new do |f|로 했습니다.
#reference : https://stackoverflow.com/questions/18853721/first-argument-in-form-cannot-contain-nil-or-be-empty-rails-4
<%= form_for(@article) do |f| %>
	<%= f.label :title%>
	<%= f.text_field :title %>
	
	<%= f.label :content %>
	<%= f.text_area :content %>
	
	<%= f.submit %>
<% end %>
```
2. 만약 값을 변경하거나 추가하고 싶다면 `<%= f.text_field :title, placeholder:'hello', class: 'hack' %>`처럼 ,를 찍고 HTML에 추가하듯이 해주면 됩니다. 다만 submit에 추가하려면 `<%= f.submit value='hi'%>`처럼 ,가 없어야 합니다.


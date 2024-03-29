defmodule Issues.GithubIssues do
  
  require Logger
  
  @user_agent [ {"User-agent", "kaze kaze@netgarazs.hu"} ]
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    Logger.info "Fetching #{user}'s project #{project}"
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_response({:ok, %{status_code: 200, body: body}}) do
    Logger.info "Successful response"
    Logger.debug fn -> inspect(body) end
    { :ok, :jsx.decode(body) }
  end
  def handle_response({:ok, %{status_code: 404, body: body}}) do
    Logger.error "Project not found"
    { :error, :jsx.decode(body) }
  end
  def handle_response({:error, %{status_code: status, body: body}}) do
    Logger.error "Error #{status} returned"
    { :error, :jsx.decode(body) }
  end
end

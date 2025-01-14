# frozen_string_literal: true
require 'rails/rails_spec_helper'

ARBRE_VIEWS_PATH = File.expand_path("../../templates", __FILE__)

class TestController < ActionController::Base
  append_view_path ARBRE_VIEWS_PATH

  def render_empty
    render "arbre/empty"
  end

  def render_simple_page
    render "arbre/simple_page"
  end

  def render_partial
    render "arbre/page_with_partial"
  end

  def render_erb_partial
    render "arbre/page_with_erb_partial"
  end

  def render_with_instance_variable
    @my_instance_var = "From Instance Var"
    render "arbre/page_with_assignment"
  end

  def render_partial_with_instance_variable
    @my_instance_var = "From Instance Var"
    render "arbre/page_with_arb_partial_and_assignment"
  end

  def render_with_block
    render "arbre/page_with_render_with_block"
  end
end

RSpec.describe TestController, "Rendering with Arbre", type: :request do
  let(:body){ response.body }

  before do
    Rails.application.routes.draw do
      get 'test/render_empty', controller: "test"
      get 'test/render_simple_page', controller: "test"
      get 'test/render_partial', controller: "test"
      get 'test/render_erb_partial', controller: "test"
      get 'test/render_with_instance_variable', controller: "test"
      get 'test/render_partial_with_instance_variable', controller: "test"
      get 'test/render_page_with_helpers', controller: "test"
      get 'test/render_with_block', controller: "test"
    end
  end

  after do
    Rails.application.reload_routes!
  end

  it "renders the empty template" do
    get "/test/render_empty"
    expect(response).to be_successful
  end

  it "renders a simple page" do
    get "/test/render_simple_page"
    expect(response).to be_successful
    expect(body).to have_css("h1", text: "Hello World")
    expect(body).to have_css("p", text: "Hello again!")
  end

  it "renders an arb partial" do
    get "/test/render_partial"
    expect(response).to be_successful
    expect(body).to eq <<~HTML
      <h1>Before Partial</h1>
      <p>Hello from a partial</p>
      <h2>After Partial</h2>
    HTML
  end

  it "renders an erb (or other) partial" do
    get "/test/render_erb_partial"
    expect(response).to be_successful
    expect(body).to eq <<~HTML
      <h1>Before Partial</h1>
      <p>Hello from an erb partial</p>
      <h2>After Partial</h2>
    HTML
  end

  it "renders with instance variables" do
    get "/test/render_with_instance_variable"
    expect(response).to be_successful
    expect(body).to have_css("h1", text: "From Instance Var")
  end

  it "renders an arbre partial with assignments" do
    get "/test/render_partial_with_instance_variable"
    expect(response).to be_successful
    expect(body).to have_css("p", text: "Partial: From Instance Var")
  end

  it "renders with a block" do
    get "/test/render_with_block"
    expect(response).to be_successful
    expect(body).to eq <<~HTML
      <h1>Before Render</h1>
      Hello from a render block
      <h2>After Render</h2>
    HTML
  end

end

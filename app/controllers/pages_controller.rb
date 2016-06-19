class PagesController < ApplicationController
  before_action :authenticate_user!, only: [
    :inside
  ]

  def home
  end

  def inside
  end
  
def posts
    @posts = Post.published.page(params[:page]).per(10)
  end

  def show_post
    @post = Post.friendly.find params[:id]
  rescue
    redirect_to root_path
  end

  
  def email
    @name = params[:name]
    @email = params[:email]
    @message = params[:message]

    if @name.blank?
      flash[:alert] = 'Please enter your name before sending a message!'
      render :contact
    elsif @email.blank? || 
          @email.scan(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i).size < 1
      flash[:alert] = 'Please enter a valid e-mail address!'
      render :contact
    elsif @message.blank? || @message.size < 1
      flash[:alert] = 'Message cannot be sent if it is blank!'
      render :contact
    elsif @message.scan( /<a href=/).size > 0 || 
          @message.scan(   /\[url=/).size > 0 || 
          @message.scan(  /\[link=/).size > 0 || 
          @message.scan(/http:\/\//).size > 0
      flash[:alert] = 'I will not accept messages with links! Sorry! :('
      render :contact
    else
      ContactMailer.contact_message(@name,@email,@message).deliver_now
      redirect_to root_path, notice: 'Your message was sent. Thank you.'
    end
  end
end

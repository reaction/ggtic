class InstantsController < ApplicationController
  # GET /instants
  # GET /instants.xml
  def index
    @instants = Instant.recommend
    @recommendations = Recommendation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @instants }
    end
  end

  # GET /instants/1
  # GET /instants/1.xml
  def show
    @instant = Instant.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @instant }
    end
  end

  # GET /instants/new
  # GET /instants/new.xml
  def new
    @instant = Instant.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @instant }
    end
  end

  # GET /instants/1/edit
  def edit
    @instant = Instant.find(params[:id])
  end

  # POST /instants
  # POST /instants.xml
  def create
    @instant = Instant.new(params[:instant])

    respond_to do |format|
      if @instant.save
        format.html { redirect_to(@instant, :notice => 'Instant was successfully created.') }
        format.xml  { render :xml => @instant, :status => :created, :location => @instant }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @instant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /instants/1
  # PUT /instants/1.xml
  def update
    @instant = Instant.find(params[:id])

    respond_to do |format|
      if @instant.update_attributes(params[:instant])
        format.html { redirect_to(@instant, :notice => 'Instant was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @instant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /instants/1
  # DELETE /instants/1.xml
  def destroy
    @instant = Instant.find(params[:id])
    @instant.destroy

    respond_to do |format|
      format.html { redirect_to(instants_url) }
      format.xml  { head :ok }
    end
  end
end

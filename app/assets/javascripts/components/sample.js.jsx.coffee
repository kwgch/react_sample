$ ->

  converter = new Showdown.converter()

  CommentBox = React.createClass
    loadCommentsFromServer: ->
      $.ajax
        url: @props.url
        dataType: 'json'
      .done (data) =>
        @setState(data: data)
      .fail (xhr, status, err) =>
        console.error @props.url, status, err.toString()

    handleCommentSubmit: (comment) ->
      # ajax通信していたらラグがあるので先に描画
      comments = @state.data
      newComments = comments.concat([comment])
      @setState(data: newComments)

      $.ajax
        url: @props.url
        dataType: 'json'
        type: 'POST'
        data: comment: comment
      .done (data) =>
        @setState(data: data)
      .fail (xhr, status, err) =>
        console.error @props.url, status, err.toString()

    getInitialState: -> data: []

    componentDidMount: ->
      @loadCommentsFromServer()
#       setInterval @loadCommentsFromServer, @props.pollInterval

    render: ->
      `<div className="commentBox">
        <h1>Comment</h1>
        <CommentList data={ this.state.data } />
        <CommentForm onCommentSubmit={ this.handleCommentSubmit } />
      </div>`

  CommentForm = React.createClass

    handleSubmit: (e) ->
      e.preventDefault()
      author = @refs.author.getDOMNode().value.trim()
      text = @refs.text.getDOMNode().value.trim()
      return unless author and text
      @props.onCommentSubmit(author: author, text: text)
      @refs.author.getDOMNode().value = ''
      @refs.text.getDOMNode().value = ''

    render: ->
      `<form className="commentForm" onSubmit={ this.handleSubmit }>
        <input type="text" className="form-control" placeholder="Your name" ref="author" />
        <input type="text" className="form-control" placeholder="Say something..." ref="text" />
        <input className="btn  btn-default" type="submit" value="Post" />
      </form>`

  CommentList = React.createClass
    render: ->
      commentNodes = @props.data.map (comment) ->
        `<Comment id={ comment.id } author={ comment.author } text={ comment.text }></Comment>`
      `<div className="commentList">
        <ul className="list-group">
          { commentNodes }
        </ul>
      </div>`

  Comment = React.createClass

    deleteComment: (e) ->
      # できればstateを利用したい
      $(@refs.comment.getDOMNode()).remove()
      $.ajax
        url: '/api/comments/' + @props.id
        dataType: 'json'
        type: 'DELETE'
        data: id: @props.id
      .done (data) =>
        console.log('delete success')
        $.growl message: data.success, type: 'success'
      .fail (xhr, status, err) =>
        console.error(status, err.toString())
        $.growl message: err.toString(), type: 'error'

    render: ->
#       rawMarkup = converter.makeHtml @props.children.toString()
      `<li className="list-group-item" ref="comment">
        { this.props.author } : { this.props.text}
        <a className="comment-delete-btn btn-link" onClick={ this.deleteComment } data-confirm="Are you sure?">
          <i className="fa fa-times-circle"></i>
        </a>
      </li>`

  data = [
    { author: 'Pete Hunt', text: 'This is one comment.' }
    { author: 'Jorden Walke', text: 'This is *another* comment.' }
  ]

#   React.render `<CommentBox data={ data } />`, document.getElementById('content')
  # 5
  React.render(
    `<CommentBox url="/api/comments" pollInterval={ 2000 } />`,
    $('#content')[0]
  )
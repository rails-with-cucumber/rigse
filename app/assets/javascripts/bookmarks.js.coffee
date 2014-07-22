InstanceCounter     = 0;
CollectionsDomID    = "bookmarks_box"
CollectionSelector  = "##{CollectionsDomID}"
ItemSelector        = "#{CollectionSelector} .bookmark_item"
AddBookmarkSelector = "add_generic_bookmark"
SortHandle          = "slide"
SortUrl             = "/portal/bookmarks/sort"
EditUrl             = "/portal/bookmarks/edit"

bookmark_identify = (div) ->
  div.readAttribute('data-bookmark-id');

class Bookmark
  constructor:(@div) ->
    @id               = bookmark_identify(@div)
    @editor           = @div.select('div.edit')[0]
    @edit_button      = @div.select('a.edit')[0]
    @link_div         = @div.select('a.link_text')[0]
    @save_button      = @div.select('button.save')[0]
    @name_field       = @div.select('input[name="name"]')[0]
    @url_field        = @div.select('input[name="url"]')[0]
    @is_visible_field = @div.select('input[name="is_visible"]')[0]

    @editing = false
    @save_button.observe 'click', (evt) =>
      @save()
    @edit_button.observe 'click', (evt) =>
      @edit()

  edit: ->
    if @editing
      @editor.hide()
      @editing = false
    else
      @editor.show()
      @editing = true

  update: (new_name, new_url, new_visibility) ->
    @link_div.update(new_name)
    @link_div.writeAttribute('href', new_url)
    @name_field.setValue(new_name)
    @url_field.setValue(new_url)
    @is_visible_field.setValue(new_visibility)

  save: ->
    @editing = false;
    new_name = @name_field.getValue()
    new_url = @url_field.getValue()
    new_visibility = @is_visible_field.getValue() == 'true'

    @editor.hide();
    new Ajax.Request EditUrl,
      method: 'post',
      parameters:
        id: @id
        name: new_name
        url: new_url
        is_visible: new_visibility
      requestHeaders:
        Accept: 'application/json'
      onSuccess: (transport) =>
        json = transport.responseText.evalJSON(true)
        @update(json.name, json.url, json.is_visible)
      onFailure: (transport) =>
        @div.highlight(startcolor: '#ff0000')


class BookmarksManager
  constructor: ->
    @bookmarks = {}
    @addBookmarks()
    @setupAddBoomarkForm()

  addBookmarks: ->
    $$(ItemSelector).each (item) =>
      @bookmarkForDiv(item)
    Sortable.create CollectionsDomID,
      'tag'     : 'div'
      'handle'  : SortHandle
      'onUpdate': (divs) => @orderChanged(divs)

  bookmarkForDiv: (div) ->
    id = bookmark_identify(div)
    @bookmarks[id] ||= @addBookMark(div)

  addBookMark: (div) ->
    new Bookmark(div)

  setupAddBoomarkForm: () ->
    form = $(AddBookmarkSelector)
    fields = form.select('.fields')[0]
    add_btn = form.select('#add_bookmark')[0]
    save_btn = form.select('#save_new_bookmark')[0]
    add_btn.observe 'click', (evt) =>
      fields.show()
      add_btn.hide()
      evt.preventDefault() # don't submit the form
    save_btn.observe 'click', (evt) =>
      fields.hide()
      add_btn.show()

  orderChanged:(divs) ->
    results = $$(ItemSelector).map (div) =>
      @bookmarkForDiv(div).id
    @changeOrder(results)

  changeOrder:(array_of_ids) ->
    console.log(array_of_ids)
    new Ajax.Request SortUrl,
      method: 'post',
      parameters:
        ids: Object.toJSON(array_of_ids)
      requestHeaders:
        Accept: 'application/json'
      onSuccess: (transport) ->
        json = transport.responseText.evalJSON(true)

document.observe "dom:loaded", ->
  window.bookmarksManager = new BookmarksManager()

{div, a, table, thead, tbody, tr, th, td, button, center} = React.DOM

window.StandardsTableClass = React.createClass

  PAGE_SIZE:    10

  displayName:  "StandardsTableClass"

  paginateUp:     ->
    start = @props.start

    if start + @PAGE_SIZE < (@props.count)
      window.searchASN(start + @PAGE_SIZE)

  paginateDown:    ->
    start = @props.start

    if start - @PAGE_SIZE > -1
      window.searchASN(start - @PAGE_SIZE)


  render: ->

    (table {className: 'asn_results_table'},

      (tbody {},

        if @props.count

          end = (@props.start + @PAGE_SIZE)
          if end > @props.count
            end = @props.count

          (tr {},
            (td {colSpan: 5, className: 'asn_results_pagination_row'}, 
         
              if @props.start - @PAGE_SIZE > -1
                (a {className: "asn_results_pagination_arrows", onClick: @paginateDown}, "<<")
              else
                "<<"
  
              " "
              "Showing " + (@props.start + 1) + " - " + end + " of " + @props.count
              " "
  
              if @props.start + @PAGE_SIZE < (@props.count) 
                (a {className: "asn_results_pagination_arrows", onClick: @paginateUp}, ">>")
              else
                ">>"
            )
          )


        (tr {},
          (th {className: 'asn_results_th'},        "Type")
          (th {className: 'asn_results_th'},        "Description")
          (th {className: 'asn_results_th'},        "Label")
          (th {className: 'asn_results_th'},        "Notation")
          (th {className: 'asn_results_th'},        "URI")
          (th {className: 'asn_results_th'},        "Grades")
          (th {className: 'asn_results_th'},        "Leaf")
          (th {className: 'asn_results_th_right'},  "Action")
        )

        for statement in @props.statements
          (StandardsRow {statement: statement, key: statement.uri, material: @props.material} )
      )
    )


window.StandardsTable = React.createFactory StandardsTableClass


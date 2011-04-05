function makeSortable() {
            var table = $('#cellared-beers');

            var headers = {};
            table.find('th').each(function(i) {
                if ($(this).hasClass('unsortable')) {
                    headers[i] = { sorter: false };
                }
            });

            table.tablesorter({headers: headers});
        }

        $(function() {
            $('#import-beers').bind('click', function(e) {
                $('div.tabs h2[data-tab-handle="upload-cellar"]').click();
            });

            var tbl = $('#cellared-beers').sortableColumns({ showPosition: true });

            var grid = hoptopus.grid({
                columnAdded: function(th) {
                    // Report to the sortableColumns thinger that a column has been added.
                    tbl.sortableColumns('addColumn', th);
                    makeSortable();
                },
                columnRemoved: function(th) {
                    // Report to the sortableColumns thinger that a column has been removed.
                    tbl.sortableColumns('removeColumn', th);
                    makeSortable();
                },
                sortable: true,
                table: $('#cellared-beers'),
                dropdown: $('#columns-button'),
                columns: <%== @grid_columns.to_json %>,
                nameFormatter: function(obj) {
                    return $('<a/>').attr('href', '/cellars/<%= @cellar.id %>/beers/' + obj.id).text(obj.name);
                }
            });

            grid.objects = hoptopus.data('cellared_beers');
            grid.rowsShown = 25;
            grid.rowClasses = ['color1', 'color2'];
			
			// This should be abstracted away from this bullshit.
            grid.breweries = hoptopus.data('cellar_breweries');
			
            $('#new-beer').bind('click', function() {
                var dialog = $('#add-beer-form');
                dialog.dialog({modal:true, width: 'auto', height: 'auto', resizable: false, title: 'Add a Beer to your Cellar'});
                
                dialog.find('form').dynamicForm({
                    errorListSelector: '#add-beer-form ul.errors',
                    submitStart: function() {
                        hoptopus.showProgress('Adding...')
                    },
                    submitDone: function() {
                        hoptopus.hideProgress();
                    },
                    success: function(data) {
                        dialog.dialog('close');
                        
                        // Add this silly row to the silly thing.
                        // TODO: Remove this stupid de-referencing!
                        var tr = grid.addSingleObject(data.beer, {front:true});

                        // We need to pulse the TR to make it obvious what it is.
                        var bg = tr[0].style.backgroundColor;
                        tr.effect('highlight', {color:'#85af22'}, 1500);
                        
                        dialog.find('form').each(function() { this.reset(); });
                        dialog.find('ul.errors').empty();
                    }
                });
            });

            // Note: This has to happen here because we have to use the useable Beers
            // thinger.
            $('#show-more').click(function() {
                // Grab 25 beers off the list and stick them in the table.
                var n = 25;
                grid.moreRows(n);

                var l = -1;
                if (grid.searchResults) {
                    l = grid.searchResults.length - hoptopus.grid.rowsShown;
                }
                else {
                    l = grid.objects.length - hoptopus.grid.rowsShown;
                }

                if (l > 0) {
                    var txt = $('#show-more').text();
                    txt = txt.replace(/\d+/, l);
                    $('#show-more').text(txt);
                }
                else if (l < 1) {
                    $('#show-more').hide();
                }
            });

            $('#clear-filters').click(function(e) {
                grid.clearFilters();
            });

            $('#cellared-beers input[type="checkbox"]').click(function() {
                var checked = $('#cellared-beers input[type="checkbox"]:checked');
                var editBeers = $('#edit-beers');

                if (editBeers.is(':disabled') && checked.length > 0) {
                    editBeers.removeAttr('disabled');
                }
            });

            var editCellar = $('#edit-cellar').dynamicForm({
                success: function(data) {
                    var dialogs = $(data).pagedDialog({ pageSelector: 'div.edit.beer', dialogOptions: { width: 'auto', height: 'auto', modal: true, resizable: false, title: 'Edit Beers'} });
                    setupDatePickers();
                  
                    var dialog = dialogs[0];

                    // Before the previous button lets insert a bunch of buttons.
                    var div = $('<div/>').addClass('submit buttons');
                    var cancelButton = $('<button/>').text('Cancel').click(function() { dialog.close(); }).attr('type', 'button');
                    var submitButton = $('<button/>').text('Save Beers');

                    div.append(cancelButton);
                    div.append(submitButton);
                    $(dialog.prevButton).before(div);

                    // Also, this data should be a dynamic form.
                    var form = $(dialog.dialog).find('form').first();
                    var dynamicForm = $(form).dynamicForm({
                        submitStart: function() {
                          hoptopus.showProgress('Saving...');
                        },
                        submitDone: function() {
                          hoptopus.hideProgress();
                        },
                        success: function(data) {
                          dialog.close();
                        },
                        error: function(errors) {
                          // Indirection for great victory!
                          errors = errors['errors'];

                          var errorsDiv= $('<div/>').addClass('errors').html('Some of your updates contain errors! The beers without errors have been saved and removed.<br/>The beers with errors remain here.');
                          errorsDiv.hide();
                          $(dialog.prevButton).parent().after(errorsDiv);
                          errorsDiv.fadeIn('fast');

                          // For each of the errors in the dialog, figure out which ones have errors and which ones don't.
                          // then rebuild the links at the bottom of the page.
                          var elements = $(dialog.dialog).find('div.edit.beer');
                          var l = elements.length;
                          for(var i = 0; i < l; i++) {
                              var element = elements[i];
                              var id = $(element).attr('data-id');

                              if(!id) {
                                  throw "ID attribute missing from page element.";
                              }

                              if(id in errors) {
                                // If there is an errors UL, then empty it and put the errors in. Otherwise,
                                // create one and add to the errors.
                                var ul = $(element).find('ul.errors') || $('<ul/>').addClass('errors');
                                ul.empty();

                                for(var j in errors[id]) {
                                  ul.append($('<li/>').text(errors[id][j]));
                                }
                              }
                              else {
                                // Not here, just get rid of it.
                                $(element).remove();
                              }
                          }

                          // Now rebuild all of the links and show the first page.
                          dialog.rebuildLinks($(dialog.dialog).find('div.edit.beer'));

                          $(dialog.dialog).find('input, select').one('focus', function() {
                            window.setTimeout(function() {
                              $(errorsDiv).fadeOut('fast', function() { $(this).remove(); });
                            }, 1500);
                          });
                        }
                    });

                    submitButton.click(function() {
                        return dynamicForm[0].submit('<%= cellar_beers_path(@cellar.user.username) %>');
                    });
                },
                error: function() {
                    alert('An error occured while submitting your edit form.');
                },
                submitStart: function () {
                    hoptopus.showProgress('Loading...');
                },
                submitDone: function() {
                    hoptopus.hideProgress();
                },
                responseType: 'html'
            });

            $('#edit-beers').click(function() {
                editCellar[0].submit('<%= edit_cellar_beers_path(@cellar.user.username) %>');
            });
        });
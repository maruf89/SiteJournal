/** @jsx React.DOM */

var MVItems = MVItems || {};

MVItems.facebook_public = React.createClass({

    // componentDidMount: function () {
    //     // grab the selector
    //     this.selector = document.querySelector('[data-reactid="' + this._rootNodeID + '"]');

    //     // connect it with Angular's infrastructure so we can use the contollers
    //     this.props.compile(this.selector)(this.$scope);
    // },

    render: function () {
        this.$scope = this.props.scope;

        var item = this.$scope.item;

        return (
            <article className="fbPublic fb item" data-ng-controller="facebookPublic">
                <div className="tag">FB</div>
                <div className="type">
                    <h3 data-ng-show="item.title"
                        data-ng-bind="item.title"></h3>
                    <p data-ng-show="item.caption">
                        {item.caption}
                    </p>
                </div>
            </article>
        )
    }
})
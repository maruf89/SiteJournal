/** @jsx React.DOM */

var MVItems = MVItems || {};

MVItems.facebook_public = React.createClass({

    // componentDidMount: MVItems.proto.componentDidMount,

    render: function () {
        var item = this.props.item;

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
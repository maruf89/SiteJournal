/** @jsx React.DOM */

var feedRepeat = React.createClass({
    render: function () {
        var template,
            parent = this.props.scope;

        return (
            <div className="inner">
                {parent.items.list.map(function(item, i) {
                    console.log(i);

                    if (!MVItems[item.type]) { return false; }

                    template = MVItems[item.type];

                    return (
                        <template scope={parent} item={item} />
                    )
                }, this)}
            </div>
        )
    }
});
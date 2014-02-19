/** @jsx React.DOM */

var feedRepeat = React.createClass({
    render: function () {
        var template,
            parent = this.props.scope,
            compile = this.props.compile,
            child;

        return (
            <div className="inner">
                {parent.items.list.map(function(item, i) {

                    if (!MVItems[item.type]) { return false; }

                    template = MVItems[item.type];
                    child = parent.$new(true)
                    child.item = item;

                    return (
                        <template scope={child} compile={compile} />
                    )
                }, this)}
            </div>
        )
    }
});
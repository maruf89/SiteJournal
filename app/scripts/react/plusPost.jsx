/** @jsx React.DOM */

MVItems.plus_post = React.createClass({

    // componentDidMount: MVItems.proto.componentDidMount,

    render: function () {
        var item = this.props.item;
        
        return (
            <article className="gpPost item" data-ng-controller="plusPost">
                <div className="tag">+</div>
                <div className="type"
                     data-ng-class="item.attachments[0].objectType">
                    <h3 data-ng-show="item.title"
                        data-ng-bind="item.title"></h3>
                    <div className="showcase">
                        <img data-ng-src="{{ item.attachments[0].fullImage.url }}" />
                    </div>
                    <p>
                        {item.attachments[0].content}
                        <span data-ng-show="item.attachments[0].url">
                            - <a href={item.attachments[0].url} target="_blank">link</a>
                        </span>
                    </p>
                </div>
            </article>
        )
    }
})
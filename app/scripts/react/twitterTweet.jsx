/** @jsx React.DOM */

var MVItems = MVItems || {};

MVItems.twitter_tweet = React.createClass({

    // componentDidMount: MVItems.proto.componentDidMount,

    render: function () {
        var item = this.props.item;

        return (
            <article className="ttTweet item" data-ng-controller="twitterTweet">
                <div className="tag">T</div>
                <div className="type" data-ng-class="tweets">
                    <p>
                        {item.text}
                    </p>
                </div>
            </article>
        )
    }
})
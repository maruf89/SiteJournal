/** @jsx React.DOM */

var MVItems = MVItems || {};

MVItems.twitter_tweet = React.createClass({

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
"use strict";

/**
 * Biovision Comments component
 *
 * @type {Object}
 */
const Comments = {
    initialized: false,
    autoInitComponents: true,
    components: {}
};

/**
 * Move new comment form to different parent comment
 *
 * Handles click on "Reply" button and moves form under parent comment.
 * Click on "Cancel" button moves form back to top-level reply.
 *
 * @type {Object}
 */
Comments.components.replyFormMover = {
    initialized: false,
    /**
     * Container for list of comments
     *
     * @type {HTMLElement}
     */
    listContainer: undefined,
    /**
     * Container for reply form
     *
     * @type {HTMLElement}
     */
    mainContainer: undefined,
    form: undefined,
    /**
     * @type {HTMLElement}
     */
    parentId: undefined,
    replyButtons: [],
    cancelButtons: [],
    replySelector: ".comment-reply-button button",
    cancelSelector: ".container button.cancel",
    /**
     * Initialize
     */
    init: function () {
        this.listContainer = document.getElementById("comments");
        this.form = document.getElementById("comment-form");

        if (this.listContainer && this.form) {
            this.parentId = document.getElementById("comment_parent_id");
            this.mainContainer = this.listContainer.querySelector(".reply-container .container");
            this.listContainer.querySelectorAll(this.replySelector).forEach(this.applyToReplyButton);
            this.listContainer.querySelectorAll(this.cancelSelector).forEach(this.applyToCancelButton);

            this.initialized = true;
        }
    },
    /**
     * Apply handler for pressing "Reply" button
     *
     * @param {HTMLElement} button
     * @type {Function}
     */
    applyToReplyButton: function (button) {
        const component = Comments.components.replyFormMover;

        component.replyButtons.push(button);
        button.addEventListener("click", component.move);
    },
    /**
     * Apply handler for pressing "Cancel" button
     *
     * @param {HTMLElement} button
     * @type {Function}
     */
    applyToCancelButton: function (button) {
        const component = Comments.components.replyFormMover;

        component.cancelButtons.push(button);
        button.addEventListener("click", component.cancel);
    },
    /**
     * Move reply form to parent comment
     *
     * @param {Event} event
     * @type {Function}
     */
    move: function (event) {
        const component = Comments.components.replyFormMover;
        const button = event.target;
        const container = button.closest(".comment-reply-block").querySelector(".container");

        if (container) {
            component.parentId.value = button.closest(".comment-item").getAttribute("data-id");
            container.appendChild(component.form);
            container.classList.remove("hidden");
        }
    },
    /**
     * Handler for pressing "Cancel" button
     *
     * @param {Event} event
     * @type {Function}
     */
    cancel: function (event) {
        const component = Comments.components.replyFormMover;
        const button = event.target;
        button.parentNode.classList.add("hidden");

        component.parentId.value = "";
        component.mainContainer.appendChild(component.form);
    }
};

Comments.components.commentApproval = {
    initialized: false,
    selector: ".js-approve-comment",
    buttons: [],
    init: function () {
        document.querySelectorAll(this.selector).forEach(this.apply);
        this.initialized = true;
    },
    apply: function (button) {
        const component = Comments.components.commentApproval;
        component.buttons.push(button);
        button.addEventListener("click", component.click);
    },
    click: function (event) {
        const button = event.target;
        const url = button.getAttribute("data-url");
        const request = Biovision.jsonAjaxRequest("put", url, function () {
            const container = button.closest("div");
            container.remove();
        }, function () {
            button.disabled = false;
        });

        button.disabled = true;
        request.send();
    }
};

Comments.components.commentDelete = {
    initialized: false,
    selector: ".js-delete-comment",
    buttons: [],
    init: function () {
        document.querySelectorAll(this.selector).forEach(this.apply);
        this.initialized = true;
    },
    apply: function (button) {
        const component = Comments.components.commentDelete;
        component.buttons.push(button);
        button.addEventListener("click", component.click);
    },
    click: function (event) {
        const button = event.target;
        const url = button.getAttribute("data-url");
        const request = Biovision.jsonAjaxRequest("delete", url, function () {
            const container = button.closest("div");
            container.remove();
        }, function () {
            button.disabled = false;
        });

        button.disabled = true;
        request.send();
    }
};

Biovision.components.comments = Comments;

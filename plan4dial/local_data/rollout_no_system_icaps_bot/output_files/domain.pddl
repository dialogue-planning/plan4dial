(define
    (domain icaps_bot)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (informed-user)
        (know__available-7)
        (available-7)
        (know__available-8)
        (available-8)
        (know__available-9)
        (available-9)
        (know__available-10)
        (available-10)
        (know__available-11)
        (available-11)
        (know__attending-7)
        (attending-7)
        (know__attending-8)
        (attending-8)
        (know__attending-9)
        (know__attending-10)
        (know__attending-11)
        (attending-11)
        (goal)
        (have-message)
        (force-statement)
    )
    (:action start
        :parameters()
        :precondition
            (and
                (not (informed-user))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         start
                (outcome inform
                    (and
                        (informed-user)
                    )
                )
            )
    )
    (:action get-attending-9
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__attending-9))
                (available-9)
            )
        :effect
            (labeled-oneof         get-response
                (outcome choose-preference
                    (and
                        (know__attending-9)
                    )
                )
                (outcome do-not-attend
                    (and
                        (know__attending-9)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action get-attending-10
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__attending-10))
                (available-10)
            )
        :effect
            (labeled-oneof         get-response
                (outcome choose-preference
                    (and
                        (know__attending-10)
                    )
                )
                (outcome do-not-attend
                    (and
                        (know__attending-10)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (know__attending-8)
                (know__attending-10)
                (know__attending-7)
                (know__attending-11)
                (not (force-statement))
                (know__attending-9)
            )
        :effect
            (labeled-oneof         finish
                (outcome finish
                    (and
                        (goal)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (force-statement)
                (have-message)
            )
        :effect
            (labeled-oneof         reset
                (outcome lock
                    (and
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
    (:action slot-fill__get-available-7
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (informed-user)
                (not (know__available-7))
            )
        :effect
            (labeled-oneof         get-response
                (outcome confirm_outcome
                    (and
                        (know__available-7)
                        (available-7)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__available-7)
                        (know__attending-7)
                        (not (available-7))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get-available-8
        :parameters()
        :precondition
            (and
                (know__available-7)
                (not (know__available-8))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         get-response
                (outcome confirm_outcome
                    (and
                        (know__available-8)
                        (available-8)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__available-8)
                        (know__attending-8)
                        (not (available-8))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get-available-9
        :parameters()
        :precondition
            (and
                (not (know__available-9))
                (know__available-8)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         get-response
                (outcome confirm_outcome
                    (and
                        (know__available-9)
                        (available-9)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__available-9)
                        (not (available-9))
                        (know__attending-9)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get-available-10
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__available-9)
                (not (know__available-10))
            )
        :effect
            (labeled-oneof         get-response
                (outcome confirm_outcome
                    (and
                        (available-10)
                        (know__available-10)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (available-10))
                        (know__available-10)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get-available-11
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__available-11))
                (know__available-10)
            )
        :effect
            (labeled-oneof         get-response
                (outcome confirm_outcome
                    (and
                        (know__available-11)
                        (available-11)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (available-11))
                        (know__available-11)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get-attending-7
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__attending-7))
                (available-7)
            )
        :effect
            (labeled-oneof         get-response
                (outcome confirm_outcome
                    (and
                        (know__attending-7)
                        (attending-7)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__attending-7)
                        (not (attending-7))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get-attending-8
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__attending-8))
                (available-8)
            )
        :effect
            (labeled-oneof         get-response
                (outcome confirm_outcome
                    (and
                        (know__attending-8)
                        (attending-8)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (attending-8))
                        (know__attending-8)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get-attending-11
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__attending-11))
                (available-11)
            )
        :effect
            (labeled-oneof         get-response
                (outcome confirm_outcome
                    (and
                        (attending-11)
                        (know__attending-11)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (attending-11))
                        (know__attending-11)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
)

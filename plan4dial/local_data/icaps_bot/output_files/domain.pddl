(define
    (domain icaps-planner)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__attending-8)
        (attending-8)
        (know__attending-dc)
        (attending-dc)
        (know__dc-interest)
        (goal)
        (have-message)
        (force-statement)
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (know__attending-8)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         complete__complete
                (outcome complete
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
            (labeled-oneof         dialogue_statement__reset
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action slot-fill__ask-july-8
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__attending-8))
            )
        :effect
            (labeled-oneof         slot-fill__ask-july-8__get-response
                (outcome confirm_outcome
                    (and
                        (attending-8)
                        (know__attending-8)
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
    (:action slot-fill__ask-dc
        :parameters()
        :precondition
            (and
                (not (know__attending-dc))
                (attending-8)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         slot-fill__ask-dc__get-response
                (outcome confirm_outcome
                    (and
                        (attending-dc)
                        (know__attending-dc)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (attending-dc))
                        (know__attending-dc)
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
    (:action slot-fill__ask-dc-pref
        :parameters()
        :precondition
            (and
                (not (know__dc-interest))
                (attending-dc)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         slot-fill__ask-dc-pref__validate-slot-fill
                (outcome dc-interest_found
                    (and
                        (know__dc-interest)
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
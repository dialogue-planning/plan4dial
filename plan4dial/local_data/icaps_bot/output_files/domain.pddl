(define
    (domain icaps-intro-planner)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__attending-8)
        (attending-8)
        (know__attending-dc)
        (attending-dc)
        (know__dc-interest)
        (know__attending-workshop-tut)
        (attending-workshop-tut)
        (know__workshop-pref)
        (know__attending-rec)
        (goal)
        (have-message)
        (force-statement)
        (forcing__slot-fill__ask-monday-evening)
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (know__workshop-pref)
                (not (forcing__slot-fill__ask-monday-evening))
                (know__attending-rec)
                (know__dc-interest)
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
                        (not (force-statement))
                        (not (have-message))
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
                (not (forcing__slot-fill__ask-monday-evening))
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
                        (know__attending-dc)
                        (force-statement)
                        (not (attending-dc))
                        (not (attending-8))
                        (know__attending-8)
                        (know__dc-interest)
                        (have-message)
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
                (attending-8)
                (not (force-statement))
                (not (know__attending-dc))
                (not (forcing__slot-fill__ask-monday-evening))
            )
        :effect
            (labeled-oneof         slot-fill__ask-dc__get-response
                (outcome confirm_outcome
                    (and
                        (know__attending-dc)
                        (attending-dc)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__attending-dc)
                        (know__dc-interest)
                        (not (attending-dc))
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
                (not (force-statement))
                (not (forcing__slot-fill__ask-monday-evening))
                (attending-dc)
                (not (know__dc-interest))
            )
        :effect
            (labeled-oneof         slot-fill__ask-dc-pref__validate-slot-fill
                (outcome dc-interest_found
                    (and
                        (force-statement)
                        (know__dc-interest)
                        (have-message)
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
    (:action slot-fill__ask-workshop-tut
        :parameters()
        :precondition
            (and
                (not (forcing__slot-fill__ask-monday-evening))
                (not (force-statement))
                (not (know__attending-workshop-tut))
            )
        :effect
            (labeled-oneof         slot-fill__ask-workshop-tut__get-response
                (outcome confirm_outcome
                    (and
                        (forcing__slot-fill__ask-monday-evening)
                        (know__attending-workshop-tut)
                        (attending-workshop-tut)
                    )
                )
                (outcome deny_outcome
                    (and
                        (force-statement)
                        (know__workshop-pref)
                        (not (attending-workshop-tut))
                        (know__attending-workshop-tut)
                        (have-message)
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
    (:action slot-fill__ask-workshop-pref
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__workshop-pref))
                (attending-workshop-tut)
                (not (forcing__slot-fill__ask-monday-evening))
            )
        :effect
            (labeled-oneof         slot-fill__ask-workshop-pref__validate-slot-fill
                (outcome workshop-pref_found
                    (and
                        (force-statement)
                        (have-message)
                        (know__workshop-pref)
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
    (:action slot-fill__ask-monday-evening
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__attending-rec))
            )
        :effect
            (labeled-oneof         slot-fill__ask-monday-evening__validate-slot-fill
                (outcome attending-rec_found
                    (and
                        (know__attending-rec)
                        (not (forcing__slot-fill__ask-monday-evening))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (not (forcing__slot-fill__ask-monday-evening))
                        (have-message)
                    )
                )
            )
    )
)
(define
    (domain day-planner)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_cuisine)
        (maybe-have_cuisine)
        (have_restaurant)
        (have_have_allergy)
        (have_allergy)
        (have_food_restriction)
        (have_conflict)
        (conflict)
        (have_low_budget)
        (low_budget)
        (have_outing_atmosphere)
        (have_goal)
        (goal)
        (have_test_fflag)
        (maybe-have_test_fflag)
        (test_fflag)
        (have-message)
        (force-statement)
        (food_restriction-value-dairy-free)
        (food_restriction-value-gluten-free)
        (cuisine-value-mexican)
        (cuisine-value-italian)
        (cuisine-value-chinese)
        (cuisine-value-dessert)
    )
    (:action get-have-allergy
        :parameters()
        :precondition
            (and
                (not (have_have_allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof set-allergy
                (outcome indicate_allergy
                    (and
                        (not (maybe-have_test_fflag))
                        (have_allergy)
                        (have_have_allergy)
                        (not (have_test_fflag))
                    )
                )
                (outcome indicate_no_allergy
                    (and
                        (not (conflict))
                        (not (have_allergy))
                        (have_have_allergy)
                        (have_conflict)
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
    (:action get-allergy
        :parameters()
        :precondition
            (and
                (have_allergy)
                (not (force-statement))
                (have_have_allergy)
            )
        :effect
            (labeled-oneof set-allergy
                (outcome update_allergy
                    (and
                        (have_food_restriction)
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
    (:action reset-preferences
        :parameters()
        :precondition
            (and
                (conflict)
                (not (force-statement))
                (have_conflict)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-values
                    (and
                        (not (have_conflict))
                        (not (food_restriction-value-dairy-free))
                        (not (have_have_allergy))
                        (not (maybe-have_cuisine))
                        (not (have_cuisine))
                        (not (cuisine-value-italian))
                        (not (food_restriction-value-gluten-free))
                        (not (have_food_restriction))
                        (force-statement)
                        (have-message)
                        (not (cuisine-value-dessert))
                        (not (cuisine-value-mexican))
                        (not (cuisine-value-chinese))
                    )
                )
            )
    )
    (:action set-restaurant
        :parameters()
        :precondition
            (and
                (not (conflict))
                (not (maybe-have_cuisine))
                (not (force-statement))
                (not (have_restaurant))
                (have_cuisine)
                (have_conflict)
            )
        :effect
            (labeled-oneof assign_restaurant
                (outcome set-mexican
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-italian
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-chinese
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-dessert
                    (and
                        (have_restaurant)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (have_restaurant)
                (not (force-statement))
            )
        :effect
            (labeled-oneof finish
                (outcome finish
                    (and
                        (have_goal)
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
            (labeled-oneof reset
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action slot-fill__get-cuisine
        :parameters()
        :precondition
            (and
                (not (maybe-have_cuisine))
                (not (have_cuisine))
                (not (force-statement))
            )
        :effect
            (labeled-oneof validate-slot-fill
                (outcome cuisine_found
                    (and
                        (not (maybe-have_cuisine))
                        (have_cuisine)
                    )
                )
                (outcome cuisine_maybe-found
                    (and
                        (not (have_cuisine))
                        (maybe-have_cuisine)
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
    (:action clarify__cuisine
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (not (force-statement))
                (maybe-have_cuisine)
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome confirm
                    (and
                        (not (maybe-have_cuisine))
                        (have_cuisine)
                    )
                )
                (outcome deny
                    (and
                        (not (maybe-have_cuisine))
                        (not (have_cuisine))
                        (not (cuisine-value-italian))
                        (not (cuisine-value-dessert))
                        (not (cuisine-value-mexican))
                        (not (cuisine-value-chinese))
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
    (:action check-conflict-1-or-1
        :parameters()
        :precondition
            (and
                (cuisine-value-mexican)
                (have_have_allergy)
                (have_allergy)
                (not (force-statement))
                (food_restriction-value-gluten-free)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (conflict)
                        (have_conflict)
                    )
                )
            )
    )
    (:action check-conflict-1-or-2
        :parameters()
        :precondition
            (and
                (have_have_allergy)
                (have_allergy)
                (food_restriction-value-dairy-free)
                (not (force-statement))
                (cuisine-value-dessert)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (conflict)
                        (have_conflict)
                    )
                )
            )
    )
    (:action check-conflict-2-or-1
        :parameters()
        :precondition
            (and
                (have_have_allergy)
                (have_food_restriction)
                (have_allergy)
                (not (force-statement))
                (cuisine-value-italian)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (maybe-have_test_fflag)
                        (have_conflict)
                        (not (conflict))
                        (not (have_test_fflag))
                    )
                )
            )
    )
    (:action check-conflict-2-or-2
        :parameters()
        :precondition
            (and
                (cuisine-value-chinese)
                (have_have_allergy)
                (have_food_restriction)
                (have_allergy)
                (not (force-statement))
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (maybe-have_test_fflag)
                        (have_conflict)
                        (not (conflict))
                        (not (have_test_fflag))
                    )
                )
            )
    )
    (:action check-conflict-2-or-3
        :parameters()
        :precondition
            (and
                (cuisine-value-mexican)
                (have_have_allergy)
                (have_allergy)
                (food_restriction-value-dairy-free)
                (not (force-statement))
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (maybe-have_test_fflag)
                        (have_conflict)
                        (not (conflict))
                        (not (have_test_fflag))
                    )
                )
            )
    )
    (:action check-conflict-2-or-4
        :parameters()
        :precondition
            (and
                (have_have_allergy)
                (have_allergy)
                (not (force-statement))
                (cuisine-value-dessert)
                (food_restriction-value-gluten-free)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (maybe-have_test_fflag)
                        (have_conflict)
                        (not (conflict))
                        (not (have_test_fflag))
                    )
                )
            )
    )
    (:action set-food_restriction
        :parameters()
        :precondition
            (and
                (not (food_restriction-value-dairy-free))
                (not (food_restriction-value-gluten-free))
                (have_food_restriction)
            )
        :effect
            (labeled-oneof set-valid-value
                (outcome dairy-free
                    (and
                        (food_restriction-value-dairy-free)
                    )
                )
                (outcome gluten-free
                    (and
                        (food_restriction-value-gluten-free)
                    )
                )
            )
    )
    (:action set-cuisine
        :parameters()
        :precondition
            (and
                (not (maybe-have_cuisine))
                (not (cuisine-value-italian))
                (have_cuisine)
                (not (cuisine-value-dessert))
                (not (cuisine-value-mexican))
                (not (cuisine-value-chinese))
            )
        :effect
            (labeled-oneof set-valid-value
                (outcome mexican
                    (and
                        (cuisine-value-mexican)
                    )
                )
                (outcome italian
                    (and
                        (cuisine-value-italian)
                    )
                )
                (outcome chinese
                    (and
                        (cuisine-value-chinese)
                    )
                )
                (outcome dessert
                    (and
                        (cuisine-value-dessert)
                    )
                )
            )
    )
)
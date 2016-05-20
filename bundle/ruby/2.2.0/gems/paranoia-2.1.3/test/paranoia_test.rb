require 'active_record'
ActiveRecord::Base.raise_in_transactional_callbacks = true if ActiveRecord::VERSION::STRING >= '4.2'

require 'minitest/autorun'
test_framework = defined?(MiniTest::Test) ? MiniTest::Test : MiniTest::Unit::TestCase

require File.expand_path(File.dirname(__FILE__) + "/../lib/paranoia")

def connect!
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', database: ':memory:'
end

def setup!
  connect!
  {
    'parent_model_with_counter_cache_columns' => 'related_models_count INTEGER DEFAULT 0',
    'parent_models' => 'deleted_at DATETIME',
    'paranoid_models' => 'parent_model_id INTEGER, deleted_at DATETIME',
    'paranoid_model_with_belongs' => 'parent_model_id INTEGER, deleted_at DATETIME, paranoid_model_with_has_one_id INTEGER',
    'paranoid_model_with_build_belongs' => 'parent_model_id INTEGER, deleted_at DATETIME, paranoid_model_with_has_one_and_build_id INTEGER, name VARCHAR(32)',
    'paranoid_model_with_anthor_class_name_belongs' => 'parent_model_id INTEGER, deleted_at DATETIME, paranoid_model_with_has_one_id INTEGER',
    'paranoid_model_with_foreign_key_belongs' => 'parent_model_id INTEGER, deleted_at DATETIME, has_one_foreign_key_id INTEGER',
    'not_paranoid_model_with_belongs' => 'parent_model_id INTEGER, paranoid_model_with_has_one_id INTEGER',
    'paranoid_model_with_has_one_and_builds' => 'parent_model_id INTEGER, color VARCHAR(32), deleted_at DATETIME, has_one_foreign_key_id INTEGER',
    'featureful_models' => 'deleted_at DATETIME, name VARCHAR(32)',
    'plain_models' => 'deleted_at DATETIME',
    'callback_models' => 'deleted_at DATETIME',
    'fail_callback_models' => 'deleted_at DATETIME',
    'related_models' => 'parent_model_id INTEGER, parent_model_with_counter_cache_column_id INTEGER, deleted_at DATETIME',
    'asplode_models' => 'parent_model_id INTEGER, deleted_at DATETIME',
    'employers' => 'deleted_at DATETIME',
    'employees' => 'deleted_at DATETIME',
    'jobs' => 'employer_id INTEGER NOT NULL, employee_id INTEGER NOT NULL, deleted_at DATETIME',
    'custom_column_models' => 'destroyed_at DATETIME',
    'custom_sentinel_models' => 'deleted_at DATETIME NOT NULL',
    'non_paranoid_models' => 'parent_model_id INTEGER',
    'polymorphic_models' => 'parent_id INTEGER, parent_type STRING, deleted_at DATETIME',
    'namespaced_paranoid_has_ones' => 'deleted_at DATETIME, paranoid_belongs_tos_id INTEGER',
    'namespaced_paranoid_belongs_tos' => 'deleted_at DATETIME, paranoid_has_one_id INTEGER',
  }.each do |table_name, columns_as_sql_string|
    ActiveRecord::Base.connection.execute "CREATE TABLE #{table_name} (id INTEGER NOT NULL PRIMARY KEY, #{columns_as_sql_string})"
  end
end

class WithDifferentConnection < ActiveRecord::Base
  establish_connection adapter: 'sqlite3', database: ':memory:'
  connection.execute 'CREATE TABLE with_different_connections (id INTEGER NOT NULL PRIMARY KEY, deleted_at DATETIME)'
  acts_as_paranoid
end

setup!

class ParanoiaTest < test_framework
  def setup
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.execute "DELETE FROM #{table}"
    end
  end

  def test_plain_model_class_is_not_paranoid
    assert_equal false, PlainModel.paranoid?
  end

  def test_paranoid_model_class_is_paranoid
    assert_equal true, ParanoidModel.paranoid?
  end

  def test_plain_models_are_not_paranoid
    assert_equal false, PlainModel.new.paranoid?
  end

  def test_paranoid_models_are_paranoid
    assert_equal true, ParanoidModel.new.paranoid?
  end

  def test_paranoid_models_to_param
    model = ParanoidModel.new
    model.save
    to_param = model.to_param

    model.destroy

    assert model.to_param
    assert_equal to_param, model.to_param
  end

  def test_destroy_behavior_for_plain_models
    model = PlainModel.new
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy

    assert_equal true, model.deleted_at.nil?

    assert_equal 0, model.class.count
    assert_equal 0, model.class.unscoped.count
  end

  # Anti-regression test for #81, which would've introduced a bug to break this test.
  def test_destroy_behavior_for_plain_models_callbacks
    model = CallbackModel.new
    model.save
    model.remove_called_variables     # clear called callback flags
    model.destroy

    assert_equal nil, model.instance_variable_get(:@update_callback_called)
    assert_equal nil, model.instance_variable_get(:@save_callback_called)
    assert_equal nil, model.instance_variable_get(:@validate_called)

    assert model.instance_variable_get(:@destroy_callback_called)
    assert model.instance_variable_get(:@after_destroy_callback_called)
    assert model.instance_variable_get(:@after_commit_callback_called)
  end


  def test_delete_behavior_for_plain_models_callbacks
    model = CallbackModel.new
    model.save
    model.remove_called_variables     # clear called callback flags
    model.delete

    assert_equal nil, model.instance_variable_get(:@update_callback_called)
    assert_equal nil, model.instance_variable_get(:@save_callback_called)
    assert_equal nil, model.instance_variable_get(:@validate_called)
    assert_equal nil, model.instance_variable_get(:@destroy_callback_called)
    assert_equal nil, model.instance_variable_get(:@after_destroy_callback_called)
    assert model.instance_variable_get(:@after_commit_callback_called)
  end

  def test_destroy_behavior_for_paranoid_models
    model = ParanoidModel.new
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy

    assert_equal false, model.deleted_at.nil?

    assert_equal 0, model.class.count
    assert_equal 1, model.class.unscoped.count
  end

  def test_update_columns_on_paranoia_destroyed
    record = ParentModel.create
    record.destroy

    assert record.update_columns deleted_at: Time.now
  end

  def test_scoping_behavior_for_paranoid_models
    parent1 = ParentModel.create
    parent2 = ParentModel.create
    p1 = ParanoidModel.create(:parent_model => parent1)
    p2 = ParanoidModel.create(:parent_model => parent2)
    p1.destroy
    p2.destroy
    assert_equal 0, parent1.paranoid_models.count
    assert_equal 1, parent1.paranoid_models.only_deleted.count
    assert_equal 1, parent1.paranoid_models.deleted.count
    p3 = ParanoidModel.create(:parent_model => parent1)
    assert_equal 2, parent1.paranoid_models.with_deleted.count
    assert_equal [p1,p3], parent1.paranoid_models.with_deleted
  end

  def test_destroy_behavior_for_custom_column_models
    model = CustomColumnModel.new
    assert_equal 0, model.class.count
    model.save!
    assert_nil model.destroyed_at
    assert_equal 1, model.class.count
    model.destroy

    assert_equal false, model.destroyed_at.nil?
    assert model.paranoia_destroyed?

    assert_equal 0, model.class.count
    assert_equal 1, model.class.unscoped.count
    assert_equal 1, model.class.only_deleted.count
    assert_equal 1, model.class.deleted.count
  end

  def test_default_sentinel_value
    assert_equal nil, ParanoidModel.paranoia_sentinel_value
  end

  def test_sentinel_value_for_custom_sentinel_models
    model = CustomSentinelModel.new
    assert_equal 0, model.class.count
    model.save!
    assert_equal DateTime.new(0), model.deleted_at
    assert_equal 1, model.class.count
    model.destroy

    assert DateTime.new(0) != model.deleted_at
    assert model.paranoia_destroyed?

    assert_equal 0, model.class.count
    assert_equal 1, model.class.unscoped.count
    assert_equal 1, model.class.only_deleted.count
    assert_equal 1, model.class.deleted.count

    model.restore
    assert_equal DateTime.new(0), model.deleted_at
    assert !model.destroyed?

    assert_equal 1, model.class.count
    assert_equal 1, model.class.unscoped.count
    assert_equal 0, model.class.only_deleted.count
    assert_equal 0, model.class.deleted.count
  end

  def test_destroy_behavior_for_featureful_paranoid_models
    model = get_featureful_model
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy

    assert_equal false, model.deleted_at.nil?

    assert_equal 0, model.class.count
    assert_equal 1, model.class.unscoped.count
  end

  def test_destroy_behavior_for_has_one_with_build_and_validation_error
    model = ParanoidModelWithHasOneAndBuild.create
    model.destroy
  end

  # Regression test for #24
  def test_chaining_for_paranoid_models
    scope = FeaturefulModel.where(:name => "foo").only_deleted
    assert_equal "foo", scope.where_values_hash['name']
    assert_equal 2, scope.where_values.count
  end

  def test_only_destroyed_scope_for_paranoid_models
    model = ParanoidModel.new
    model.save
    model.destroy
    model2 = ParanoidModel.new
    model2.save

    assert_equal model, ParanoidModel.only_deleted.last
    assert_equal false, ParanoidModel.only_deleted.include?(model2)
  end

  def test_default_scope_for_has_many_relationships
    parent = ParentModel.create
    assert_equal 0, parent.related_models.count

    child = parent.related_models.create
    assert_equal 1, parent.related_models.count

    child.destroy
    assert_equal false, child.deleted_at.nil?

    assert_equal 0, parent.related_models.count
    assert_equal 1, parent.related_models.unscoped.count
  end

  def test_default_scope_for_has_many_through_relationships
    employer = Employer.create
    employee = Employee.create
    assert_equal 0, employer.jobs.count
    assert_equal 0, employer.employees.count
    assert_equal 0, employee.jobs.count
    assert_equal 0, employee.employers.count

    job = Job.create :employer => employer, :employee => employee
    assert_equal 1, employer.jobs.count
    assert_equal 1, employer.employees.count
    assert_equal 1, employee.jobs.count
    assert_equal 1, employee.employers.count

    employee2 = Employee.create
    job2 = Job.create :employer => employer, :employee => employee2
    employee2.destroy
    assert_equal 2, employer.jobs.count
    assert_equal 1, employer.employees.count

    job.destroy
    assert_equal 1, employer.jobs.count
    assert_equal 0, employer.employees.count
    assert_equal 0, employee.jobs.count
    assert_equal 0, employee.employers.count
  end

  def test_delete_behavior_for_callbacks
    model = CallbackModel.new
    model.save
    model.delete
    assert_equal nil, model.instance_variable_get(:@destroy_callback_called)
  end

  def test_destroy_behavior_for_callbacks
    model = CallbackModel.new
    model.save
    model.destroy
    assert model.instance_variable_get(:@destroy_callback_called)
  end

  def test_destroy_on_readonly_record
    # Just to demonstrate the AR behaviour
    model = NonParanoidModel.create!
    model.readonly!
    assert_raises ActiveRecord::ReadOnlyRecord do
      model.destroy
    end

    # Mirrors behaviour above
    model = ParanoidModel.create!
    model.readonly!
    assert_raises ActiveRecord::ReadOnlyRecord do
      model.destroy
    end
  end

  def test_destroy_on_really_destroyed_record
    model = ParanoidModel.create!
    model.really_destroy!
    assert model.really_destroyed?
    assert model.paranoia_destroyed?
    model.destroy
    assert model.really_destroyed?
    assert model.paranoia_destroyed?
  end

  def test_destroy_on_unsaved_record
    # Just to demonstrate the AR behaviour
    model = NonParanoidModel.new
    model.destroy!
    assert model.really_destroyed?
    model.destroy!
    assert model.really_destroyed?

    # Mirrors behaviour above
    model = ParanoidModel.new
    model.destroy!
    assert model.paranoia_destroyed?
    model.destroy!
    assert model.paranoia_destroyed?
  end

  def test_restore
    model = ParanoidModel.new
    model.save
    id = model.id
    model.destroy

    assert model.paranoia_destroyed?

    model = ParanoidModel.only_deleted.find(id)
    model.restore!
    model.reload

    assert_equal false, model.paranoia_destroyed?
  end

  def test_restore_on_object_return_self
    model = ParanoidModel.create
    model.destroy

    assert_equal model.class, model.restore.class
  end

  # Regression test for #92
  def test_destroy_twice
    model = ParanoidModel.new
    model.save
    model.destroy
    model.destroy

    assert_equal 1, ParanoidModel.unscoped.where(id: model.id).count
  end

  # Regression test for #92
  def test_destroy_bang_twice
    model = ParanoidModel.new
    model.save!
    model.destroy!
    model.destroy!

    assert_equal 1, ParanoidModel.unscoped.where(id: model.id).count
  end

  def test_destroy_return_value_on_success
    model = ParanoidModel.create
    return_value = model.destroy

    assert_equal(return_value, model)
  end

  def test_destroy_return_value_on_failure
    model = FailCallbackModel.create
    return_value = model.destroy

    assert_equal(return_value, false)
  end

  def test_restore_behavior_for_callbacks
    model = CallbackModel.new
    model.save
    id = model.id
    model.destroy

    assert model.paranoia_destroyed?

    model = CallbackModel.only_deleted.find(id)
    model.restore!
    model.reload

    assert model.instance_variable_get(:@restore_callback_called)
  end

  def test_really_destroy
    model = ParanoidModel.new
    model.save
    model.really_destroy!
    refute ParanoidModel.unscoped.exists?(model.id)
  end

  def test_real_destroy_dependent_destroy
    parent = ParentModel.create
    child1 = parent.very_related_models.create
    child2 = parent.non_paranoid_models.create
    child3 = parent.create_non_paranoid_model

    parent.really_destroy!

    refute RelatedModel.unscoped.exists?(child1.id)
    refute NonParanoidModel.unscoped.exists?(child2.id)
    refute NonParanoidModel.unscoped.exists?(child3.id)
  end

  def test_real_destroy_dependent_destroy_after_normal_destroy
    parent = ParentModel.create
    child = parent.very_related_models.create
    parent.destroy
    parent.really_destroy!
    refute RelatedModel.unscoped.exists?(child.id)
  end

  def test_real_destroy_dependent_destroy_after_normal_destroy_does_not_delete_other_children
    parent_1 = ParentModel.create
    child_1 = parent_1.very_related_models.create

    parent_2 = ParentModel.create
    child_2 = parent_2.very_related_models.create
    parent_1.destroy
    parent_1.really_destroy!
    assert RelatedModel.unscoped.exists?(child_2.id)
  end

  def test_really_delete
    model = ParanoidModel.new
    model.save
    model.really_delete

    refute ParanoidModel.unscoped.exists?(model.id)
  end

  def test_multiple_restore
    a = ParanoidModel.new
    a.save
    a_id = a.id
    a.destroy

    b = ParanoidModel.new
    b.save
    b_id = b.id
    b.destroy

    c = ParanoidModel.new
    c.save
    c_id = c.id
    c.destroy

    ParanoidModel.restore([a_id, c_id])

    a.reload
    b.reload
    c.reload

    refute a.paranoia_destroyed?
    assert b.paranoia_destroyed?
    refute c.paranoia_destroyed?
  end

  def test_restore_with_associations
    parent = ParentModel.create
    first_child = parent.very_related_models.create
    second_child = parent.non_paranoid_models.create

    parent.destroy
    assert_equal false, parent.deleted_at.nil?
    assert_equal false, first_child.reload.deleted_at.nil?
    assert_equal true, second_child.destroyed?

    parent.restore!
    assert_equal true, parent.deleted_at.nil?
    assert_equal false, first_child.reload.deleted_at.nil?
    assert_equal true, second_child.destroyed?

    parent.destroy
    parent.restore(:recursive => true)
    assert_equal true, parent.deleted_at.nil?
    assert_equal true, first_child.reload.deleted_at.nil?
    assert_equal true, second_child.destroyed?

    parent.destroy
    ParentModel.restore(parent.id, :recursive => true)
    assert_equal true, parent.reload.deleted_at.nil?
    assert_equal true, first_child.reload.deleted_at.nil?
    assert_equal true, second_child.destroyed?
  end

  # regression tests for #118
  def test_restore_with_has_one_association
    # setup and destroy test objects
    hasOne = ParanoidModelWithHasOne.create
    belongsTo = ParanoidModelWithBelong.create
    anthorClassName = ParanoidModelWithAnthorClassNameBelong.create
    foreignKey = ParanoidModelWithForeignKeyBelong.create
    notParanoidModel = NotParanoidModelWithBelong.create

    hasOne.paranoid_model_with_belong = belongsTo
    hasOne.class_name_belong = anthorClassName
    hasOne.paranoid_model_with_foreign_key_belong = foreignKey
    hasOne.not_paranoid_model_with_belong = notParanoidModel
    hasOne.save!

    hasOne.destroy
    assert_equal false, hasOne.deleted_at.nil?
    assert_equal false, belongsTo.deleted_at.nil?

    # Does it restore has_one associations?
    hasOne.restore(:recursive => true)
    hasOne.save!

    assert_equal true, hasOne.reload.deleted_at.nil?
    assert_equal true, belongsTo.reload.deleted_at.nil?, "#{belongsTo.deleted_at}"
    assert_equal true, notParanoidModel.destroyed?
    assert ParanoidModelWithBelong.with_deleted.reload.count != 0, "There should be a record"
    assert ParanoidModelWithAnthorClassNameBelong.with_deleted.reload.count != 0, "There should be an other record"
    assert ParanoidModelWithForeignKeyBelong.with_deleted.reload.count != 0, "There should be a foreign_key record"
  end

  def test_new_restore_with_has_one_association
    # setup and destroy test objects
    hasOne = ParanoidModelWithHasOne.create
    belongsTo = ParanoidModelWithBelong.create
    anthorClassName = ParanoidModelWithAnthorClassNameBelong.create
    foreignKey = ParanoidModelWithForeignKeyBelong.create
    notParanoidModel = NotParanoidModelWithBelong.create

    hasOne.paranoid_model_with_belong = belongsTo
    hasOne.class_name_belong = anthorClassName
    hasOne.paranoid_model_with_foreign_key_belong = foreignKey
    hasOne.not_paranoid_model_with_belong = notParanoidModel
    hasOne.save!

    hasOne.destroy
    assert_equal false, hasOne.deleted_at.nil?
    assert_equal false, belongsTo.deleted_at.nil?

    # Does it restore has_one associations?
    newHasOne = ParanoidModelWithHasOne.with_deleted.find(hasOne.id)
    newHasOne.restore(:recursive => true)
    newHasOne.save!

    assert_equal true, hasOne.reload.deleted_at.nil?
    assert_equal true, belongsTo.reload.deleted_at.nil?, "#{belongsTo.deleted_at}"
    assert_equal true, notParanoidModel.destroyed?
    assert ParanoidModelWithBelong.with_deleted.reload.count != 0, "There should be a record"
    assert ParanoidModelWithAnthorClassNameBelong.with_deleted.reload.count != 0, "There should be an other record"
    assert ParanoidModelWithForeignKeyBelong.with_deleted.reload.count != 0, "There should be a foreign_key record"
  end

  def test_model_restore_with_has_one_association
    # setup and destroy test objects
    hasOne = ParanoidModelWithHasOne.create
    belongsTo = ParanoidModelWithBelong.create
    anthorClassName = ParanoidModelWithAnthorClassNameBelong.create
    foreignKey = ParanoidModelWithForeignKeyBelong.create
    notParanoidModel = NotParanoidModelWithBelong.create

    hasOne.paranoid_model_with_belong = belongsTo
    hasOne.class_name_belong = anthorClassName
    hasOne.paranoid_model_with_foreign_key_belong = foreignKey
    hasOne.not_paranoid_model_with_belong = notParanoidModel
    hasOne.save!

    hasOne.destroy
    assert_equal false, hasOne.deleted_at.nil?
    assert_equal false, belongsTo.deleted_at.nil?

    # Does it restore has_one associations?
    ParanoidModelWithHasOne.restore(hasOne.id, :recursive => true)
    hasOne.save!

    assert_equal true, hasOne.reload.deleted_at.nil?
    assert_equal true, belongsTo.reload.deleted_at.nil?, "#{belongsTo.deleted_at}"
    assert_equal true, notParanoidModel.destroyed?
    assert ParanoidModelWithBelong.with_deleted.reload.count != 0, "There should be a record"
    assert ParanoidModelWithAnthorClassNameBelong.with_deleted.reload.count != 0, "There should be an other record"
    assert ParanoidModelWithForeignKeyBelong.with_deleted.reload.count != 0, "There should be a foreign_key record"
  end

  def test_restore_with_nil_has_one_association
    # setup and destroy test object
    hasOne = ParanoidModelWithHasOne.create
    hasOne.destroy
    assert_equal false, hasOne.reload.deleted_at.nil?

    # Does it raise NoMethodException on restore of nil
    hasOne.restore(:recursive => true)

    assert hasOne.reload.deleted_at.nil?
  end

  def test_restore_with_module_scoped_has_one_association
    # setup and destroy test object
    hasOne = Namespaced::ParanoidHasOne.create
    hasOne.destroy
    assert_equal false, hasOne.reload.deleted_at.nil?

    # Does it raise "uninitialized constant ParanoidBelongsTo"
    # on restore of ParanoidHasOne?
    hasOne.restore(:recursive => true)

    assert hasOne.reload.deleted_at.nil?
  end

  # covers #185
  def test_restoring_recursive_has_one_restores_correct_object
    hasOnes = 2.times.map { ParanoidModelWithHasOne.create }
    belongsTos = 2.times.map { ParanoidModelWithBelong.create }

    hasOnes[0].update paranoid_model_with_belong: belongsTos[0]
    hasOnes[1].update paranoid_model_with_belong: belongsTos[1]

    hasOnes.each(&:destroy)

    ParanoidModelWithHasOne.restore(hasOnes[1].id, :recursive => true)
    hasOnes.each(&:reload)
    belongsTos.each(&:reload)

    # without #185, belongsTos[0] will be restored instead of belongsTos[1]
    refute_nil hasOnes[0].deleted_at
    refute_nil belongsTos[0].deleted_at
    assert_nil hasOnes[1].deleted_at
    assert_nil belongsTos[1].deleted_at
  end

  # covers #131
  def test_has_one_really_destroy_with_nil
    model = ParanoidModelWithHasOne.create
    model.really_destroy!

    refute ParanoidModelWithBelong.unscoped.exists?(model.id)
  end

  def test_has_one_really_destroy_with_record
    model = ParanoidModelWithHasOne.create { |record| record.build_paranoid_model_with_belong }
    model.really_destroy!

    refute ParanoidModelWithBelong.unscoped.exists?(model.id)
  end

  def test_observers_notified
    a = ParanoidModelWithObservers.create
    a.destroy
    a.restore!

    assert a.observers_notified.select {|args| args == [:before_restore, a]}
    assert a.observers_notified.select {|args| args == [:after_restore, a]}
  end

  def test_observers_not_notified_if_not_supported
    a = ParanoidModelWithObservers.create
    a.destroy
    a.restore!
    # essentially, we're just ensuring that this doesn't crash
  end

  def test_i_am_the_destroyer
    expected = %Q{
      Sharon: "There should be a method called I_AM_THE_DESTROYER!"
      Ryan:   "What should this method do?"
      Sharon: "It should fix all the spelling errors on the page!"
}
    assert_output expected do
      ParanoidModel.I_AM_THE_DESTROYER!
    end
  end

  def test_destroy_fails_if_callback_raises_exception
    parent = AsplodeModel.create

    assert_raises(StandardError) { parent.destroy }

    #transaction should be rolled back, so parent NOT deleted
    refute parent.destroyed?, 'Parent record was destroyed, even though AR callback threw exception'
  end

  def test_destroy_fails_if_association_callback_raises_exception
    parent = ParentModel.create
    children = []
    3.times { children << parent.asplode_models.create }

    assert_raises(StandardError) { parent.destroy }

    #transaction should be rolled back, so parent and children NOT deleted
    refute parent.destroyed?, 'Parent record was destroyed, even though AR callback threw exception'
    refute children.any?(&:destroyed?), 'Child record was destroyed, even though AR callback threw exception'
  end

  def test_restore_model_with_different_connection
    ActiveRecord::Base.remove_connection # Disconnect the main connection
    a = WithDifferentConnection.create
    a.destroy!
    a.restore!
    # This test passes if no exception is raised
  ensure
    setup! # Reconnect the main connection
  end

  def test_restore_clear_association_cache_if_associations_present
    parent = ParentModel.create
    3.times { parent.very_related_models.create }

    parent.destroy

    assert_equal 0, parent.very_related_models.count
    assert_equal 0, parent.very_related_models.size

    parent.restore(recursive: true)

    assert_equal 3, parent.very_related_models.count
    assert_equal 3, parent.very_related_models.size
  end

  def test_model_without_db_connection
    ActiveRecord::Base.remove_connection

    NoConnectionModel.class_eval{ acts_as_paranoid }
  ensure
    setup!
  end

  def test_restore_recursive_on_polymorphic_has_one_association
    parent = ParentModel.create
    polymorphic = PolymorphicModel.create(parent: parent)

    parent.destroy

    assert_equal 0, polymorphic.class.count

    parent.restore(recursive: true)

    assert_equal 1, polymorphic.class.count
  end

  # Ensure that we're checking parent_type when restoring
  def test_missing_restore_recursive_on_polymorphic_has_one_association
    parent = ParentModel.create
    polymorphic = PolymorphicModel.create(parent_id: parent.id, parent_type: 'ParanoidModel')

    parent.destroy
    polymorphic.destroy

    assert_equal 0, polymorphic.class.count

    parent.restore(recursive: true)

    assert_equal 0, polymorphic.class.count
  end

  def test_counter_cache_column_update_on_destroy#_and_restore_and_really_destroy
    parent_model_with_counter_cache_column = ParentModelWithCounterCacheColumn.create
    related_model = parent_model_with_counter_cache_column.related_models.create

    assert_equal 1, parent_model_with_counter_cache_column.reload.related_models_count
    related_model.destroy
    assert_equal 0, parent_model_with_counter_cache_column.reload.related_models_count
  end

  def test_callbacks_for_counter_cache_column_update_on_destroy
    parent_model_with_counter_cache_column = ParentModelWithCounterCacheColumn.create
    related_model = parent_model_with_counter_cache_column.related_models.create

    assert_equal nil, related_model.instance_variable_get(:@after_destroy_callback_called)
    assert_equal nil, related_model.instance_variable_get(:@after_commit_on_destroy_callback_called)

    related_model.destroy

    assert related_model.instance_variable_get(:@after_destroy_callback_called)
    # assert related_model.instance_variable_get(:@after_commit_on_destroy_callback_called)
  end

  # TODO: find a fix for Rails 4.1
  if ActiveRecord::VERSION::STRING !~ /\A4\.1/
    def test_counter_cache_column_update_on_really_destroy
      parent_model_with_counter_cache_column = ParentModelWithCounterCacheColumn.create
      related_model = parent_model_with_counter_cache_column.related_models.create

      assert_equal 1, parent_model_with_counter_cache_column.reload.related_models_count
      related_model.really_destroy!
      assert_equal 0, parent_model_with_counter_cache_column.reload.related_models_count
    end
  end

  # TODO: find a fix for Rails 4.0 and 4.1
  if ActiveRecord::VERSION::STRING >= '4.2'
    def test_callbacks_for_counter_cache_column_update_on_really_destroy!
      parent_model_with_counter_cache_column = ParentModelWithCounterCacheColumn.create
      related_model = parent_model_with_counter_cache_column.related_models.create

      assert_equal nil, related_model.instance_variable_get(:@after_destroy_callback_called)
      assert_equal nil, related_model.instance_variable_get(:@after_commit_on_destroy_callback_called)

      related_model.really_destroy!

      assert related_model.instance_variable_get(:@after_destroy_callback_called)
      assert related_model.instance_variable_get(:@after_commit_on_destroy_callback_called)
    end
  end

  private
  def get_featureful_model
    FeaturefulModel.new(:name => "not empty")
  end
end

# Helper classes

class ParanoidModel < ActiveRecord::Base
  belongs_to :parent_model
  acts_as_paranoid
end

class FailCallbackModel < ActiveRecord::Base
  belongs_to :parent_model
  acts_as_paranoid

  before_destroy { |_| false }
end

class FeaturefulModel < ActiveRecord::Base
  acts_as_paranoid
  validates :name, :presence => true, :uniqueness => true
end

class PlainModel < ActiveRecord::Base
end

class CallbackModel < ActiveRecord::Base
  acts_as_paranoid
  before_destroy {|model| model.instance_variable_set :@destroy_callback_called, true }
  before_restore {|model| model.instance_variable_set :@restore_callback_called, true }
  before_update  {|model| model.instance_variable_set :@update_callback_called, true }
  before_save    {|model| model.instance_variable_set :@save_callback_called, true}

  after_destroy  {|model| model.instance_variable_set :@after_destroy_callback_called, true }
  after_commit   {|model| model.instance_variable_set :@after_commit_callback_called, true }

  validate       {|model| model.instance_variable_set :@validate_called, true }

  def remove_called_variables
    instance_variables.each {|name| (name.to_s.end_with?('_called')) ? remove_instance_variable(name) : nil}
  end
end

class ParentModel < ActiveRecord::Base
  acts_as_paranoid
  has_many :paranoid_models
  has_many :related_models
  has_many :very_related_models, :class_name => 'RelatedModel', dependent: :destroy
  has_many :non_paranoid_models, dependent: :destroy
  has_one :non_paranoid_model, dependent: :destroy
  has_many :asplode_models, dependent: :destroy
  has_one :polymorphic_model, as: :parent, dependent: :destroy
end

class ParentModelWithCounterCacheColumn < ActiveRecord::Base
  has_many :related_models
end

class RelatedModel < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :parent_model
  belongs_to :parent_model_with_counter_cache_column, counter_cache: true

  after_destroy do |model|
    if parent_model_with_counter_cache_column && parent_model_with_counter_cache_column.reload.related_models_count == 0
      model.instance_variable_set :@after_destroy_callback_called, true
    end
  end
  after_commit :set_after_commit_on_destroy_callback_called, on: :destroy

  def set_after_commit_on_destroy_callback_called
    if parent_model_with_counter_cache_column && parent_model_with_counter_cache_column.reload.related_models_count == 0
      self.instance_variable_set :@after_commit_on_destroy_callback_called, true
    end
  end
end

class Employer < ActiveRecord::Base
  acts_as_paranoid
  has_many :jobs
  has_many :employees, :through => :jobs
end

class Employee < ActiveRecord::Base
  acts_as_paranoid
  has_many :jobs
  has_many :employers, :through => :jobs
end

class Job < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :employer
  belongs_to :employee
end

class CustomColumnModel < ActiveRecord::Base
  acts_as_paranoid column: :destroyed_at
end

class CustomSentinelModel < ActiveRecord::Base
  acts_as_paranoid sentinel_value: DateTime.new(0)
end

class NonParanoidModel < ActiveRecord::Base
end

class ParanoidModelWithObservers < ParanoidModel
  def observers_notified
    @observers_notified ||= []
  end

  def self.notify_observer(*args)
    observers_notified << args
  end
end

class ParanoidModelWithoutObservers < ParanoidModel
  self.class.send(remove_method :notify_observers) if method_defined?(:notify_observers)
end

# refer back to regression test for #118
class ParanoidModelWithHasOne < ParanoidModel
  has_one :paranoid_model_with_belong, :dependent => :destroy
  has_one :class_name_belong, :dependent => :destroy, :class_name => "ParanoidModelWithAnthorClassNameBelong"
  has_one :paranoid_model_with_foreign_key_belong, :dependent => :destroy, :foreign_key => "has_one_foreign_key_id"
  has_one :not_paranoid_model_with_belong, :dependent => :destroy
end

class ParanoidModelWithHasOneAndBuild < ActiveRecord::Base
  has_one :paranoid_model_with_build_belong, :dependent => :destroy
  validates :color, :presence => true
  after_validation :build_paranoid_model_with_build_belong, on: :create

  private
  def build_paranoid_model_with_build_belong
    super.tap { |child| child.name = "foo" }
  end
end

class ParanoidModelWithBuildBelong < ActiveRecord::Base
  acts_as_paranoid
  validates :name, :presence => true
  belongs_to :paranoid_model_with_has_one_and_build
end

class ParanoidModelWithBelong < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :paranoid_model_with_has_one
end

class ParanoidModelWithAnthorClassNameBelong < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :paranoid_model_with_has_one
end

class ParanoidModelWithForeignKeyBelong < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :paranoid_model_with_has_one
end

class NotParanoidModelWithBelong < ActiveRecord::Base
  belongs_to :paranoid_model_with_has_one
end

class FlaggedModel < PlainModel
  acts_as_paranoid :flag_column => :is_deleted
end

class FlaggedModelWithCustomIndex < PlainModel
  acts_as_paranoid :flag_column => :is_deleted, :indexed_column => :is_deleted
end

class AsplodeModel < ActiveRecord::Base
  acts_as_paranoid
  before_destroy do |r|
    raise StandardError, 'ASPLODE!'
  end
end

class NoConnectionModel < ActiveRecord::Base
end

class PolymorphicModel < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :parent, polymorphic: true
end

module Namespaced
  def self.table_name_prefix
    "namespaced_"
  end

  class ParanoidHasOne < ActiveRecord::Base
    acts_as_paranoid
    has_one :paranoid_belongs_to, dependent: :destroy
  end

  class ParanoidBelongsTo < ActiveRecord::Base
    acts_as_paranoid
    belongs_to :paranoid_has_one
  end
end

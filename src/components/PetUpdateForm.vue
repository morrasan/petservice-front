<script setup>
  import { ref } from 'vue'
  import axios from 'axios'

  const petUpdateFormForm = ref(null);
  const isFormValid = ref(false)
  const isUpdateButtonDisabled = ref(false)

  const petId = ref()
  const petName = ref('')
  const petCategory = ref()
  const petStatus = ref()
  const petTags = ref([])

  const categories = ref([
    { id: 1, name: 'Dogs' },
    { id: 2, name: 'Cats' },
    { id: 3, name: 'Birds' },
  ])

  const statuses = ref([
    'available',
    'pending',
    'sold',
  ])

  const tags = ref([
    { id: 1, name: 'cuteanimals' },
    { id: 2, name: 'partyanimals' },
    { id: 3, name: 'babyanimals' },
    { id: 4, name: 'exoticanimals' }
  ])

  const isStoreError = ref(false)

  const rules = {
    petId: [
      v => (!isNaN(v) && Number(v) >= 1) || 'Please enter a number greater than or equal to 1'
    ],
    petName: [
      v => !!v || 'Name is required',
      v => (v && v.length > 2) || 'Please enter more than 2 characters'
    ],
    petCategory: [
      v => !!v || 'Category is required'
    ],
    petStatus: [
      v => !!v || 'Status is required'
    ],
    petImage: [
      v => !!v[0] || 'Image is required',
      v => v[0]?.size < 5000000 || 'The maximum file size is 5MB'
    ]
  }

  const storeData = () => {

    isStoreError.value = false

    // run validation
    petUpdateFormForm.value.validate()

    if (isFormValid.value) {

      isUpdateButtonDisabled.value = true

      // Prepare post data
      const formData = new FormData()

      formData.append('name', petName.value)
      formData.append('category_id', petCategory.value)
      formData.append('status', petStatus.value)

      const tags = petTags.value;

      for (let i = 0; i < tags.length; i++) {
        formData.append('tags[]', tags[i]);
      }

      // get API url from .env
      const url = import.meta.env.VITE_API_URL

      axios.post(`${url}/api/pet/${petId.value}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json'
        }

      }).then(() => {

        // set default values
        petId.value = null
        petName.value = ''
        petCategory.value = null
        petStatus.value = null
        petTags.value = []

        petUpdateFormForm.value.resetValidation()

        // fetch new data from back to list in FileList component
        document.dispatchEvent(new CustomEvent('fetchData'))

      }).catch(error => {

        isStoreError.value = true
        console.error('error', error);

      }).finally(() => {

        isUpdateButtonDisabled.value = false
      })
    }
  }
</script>

<template>
  <div class="mt-5">
    <h3 class="text-center mb-3">Update the Pet</h3>
    <v-alert
        v-if="isStoreError"
        color="error"
        class="ma-3"
        closable
    >
      Something went wrong, please try again later
    </v-alert>
    <v-form
        ref="petUpdateFormForm"
        v-model="isFormValid"
    >
      <v-text-field
        v-model.trim="petId"
        :rules="rules.petId"
        variant="outlined"
        rounded
        label="Pet's ID"
        class="mb-2"
      ></v-text-field>
      <v-text-field
        v-model.trim="petName"
        :rules="rules.petName"
        variant="outlined"
        rounded
        label="Name"
        class="mb-2"
      ></v-text-field>
      <v-select
        v-model="petCategory"
        :items="categories"
        :rules="rules.petCategory"
        item-title="name"
        item-value="id"
        label="Categories"
        variant="outlined"
        rounded
      ></v-select>
      <v-select
        v-model="petStatus"
        :items="statuses"
        :rules="rules.petStatus"
        label="Status"
        variant="outlined"
        rounded
      ></v-select>
      <v-select
        v-model="petTags"
        :items="tags"
        item-title="name"
        item-value="id"
        label="Tags"
        chips
        multiple
        variant="outlined"
        rounded
      ></v-select>
    </v-form>
    <v-btn
      block
      rounded="xl"
      color="green"
      size="x-large"
      :disabled="isUpdateButtonDisabled"
      @click="storeData"
    >
      Update
    </v-btn>
  </div>
</template>

<style scoped>
.v-alert {
  border-radius: 24px;
}
</style>
